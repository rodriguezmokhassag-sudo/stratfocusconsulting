"""Ecriture minimale d'un fichier Compound File Binary (MS-CFB, version 3).

Utilise pour produire vbaProject.bin. Gere les storages imbriques, le
mini-stream (< 4096 octets) et un arbre rouge-noir valide pour chaque storage.
"""
import struct

SECTOR = 512
MINI = 64
CUTOFF = 4096
FREESECT = 0xFFFFFFFF
ENDOFCHAIN = 0xFFFFFFFE
FATSECT = 0xFFFFFFFD
NOSTREAM = 0xFFFFFFFF


class _Entry:
    def __init__(self, name, kind, data=b""):
        self.name = name
        self.kind = kind  # 1 storage, 2 stream, 5 root
        self.data = data
        self.children = []
        self.left = self.right = self.child = NOSTREAM
        self.color = 1
        self.start = ENDOFCHAIN if kind != 1 else 0
        self.size = 0
        self.sid = None


def _key(name):
    return (len(name), name.upper())


def _build_tree(entries):
    """Arbre binaire equilibre ; noeuds du niveau le plus profond en rouge."""
    entries = sorted(entries, key=lambda e: _key(e.name))
    depths = {}

    def rec(lo, hi, depth):
        if lo > hi:
            return None
        mid = (lo + hi) // 2
        node = entries[mid]
        depths[id(node)] = depth
        left = rec(lo, mid - 1, depth + 1)
        right = rec(mid + 1, hi, depth + 1)
        node.left = left.sid if left else NOSTREAM
        node.right = right.sid if right else NOSTREAM
        return node

    root = rec(0, len(entries) - 1, 0)
    maxd = max(depths.values()) if depths else 0
    for e in entries:
        e.color = 0 if (maxd > 0 and depths[id(e)] == maxd) else 1
    return root


def write_cfb(tree):
    """tree : dict {nom: bytes | dict} decrivant les storages et streams."""
    root = _Entry("Root Entry", 5)
    order = [root]

    def add(parent, d):
        for name, val in d.items():
            if isinstance(val, dict):
                e = _Entry(name, 1)
                parent.children.append(e)
                order.append(e)
                add(e, val)
            else:
                e = _Entry(name, 2, bytes(val))
                parent.children.append(e)
                order.append(e)

    add(root, tree)
    for i, e in enumerate(order):
        e.sid = i
    for e in order:
        if e.children:
            top = _build_tree(e.children)
            e.child = top.sid
    root.color = 1

    # Mini stream
    mini = bytearray()
    minifat = []
    big_streams = []
    for e in order:
        if e.kind != 2:
            continue
        e.size = len(e.data)
        if e.size == 0:
            e.start = ENDOFCHAIN
        elif e.size < CUTOFF:
            first = len(mini) // MINI
            n = (e.size + MINI - 1) // MINI
            for k in range(n):
                minifat.append(first + k + 1 if k < n - 1 else ENDOFCHAIN)
            e.start = first
            mini += e.data + b"\0" * (n * MINI - e.size)
        else:
            big_streams.append(e)

    def nsec(size):
        return (size + SECTOR - 1) // SECTOR

    dir_bytes_len = len(order) * 128
    n_dir = nsec(dir_bytes_len)
    n_minifat = nsec(len(minifat) * 4)
    n_mini = nsec(len(mini))
    n_big = sum(nsec(e.size) for e in big_streams)
    n_data = n_dir + n_minifat + n_mini + n_big
    n_fat = 1
    while n_fat * (SECTOR // 4) < n_data + n_fat:
        n_fat += 1
    assert n_fat <= 109, "fichier trop volumineux pour ce writer"

    fat = []
    sectors = []  # contenus des secteurs dans l'ordre

    def alloc(data, count):
        start = len(fat)
        for k in range(count):
            fat.append(start + k + 1 if k < count - 1 else ENDOFCHAIN)
        buf = data + b"\0" * (count * SECTOR - len(data))
        for k in range(count):
            sectors.append(buf[k * SECTOR:(k + 1) * SECTOR])
        return start if count else ENDOFCHAIN

    dir_start_placeholder = len(fat)
    alloc(b"", n_dir)  # remplacé plus tard
    minifat_start = alloc(b"".join(struct.pack("<I", v) for v in minifat), n_minifat)
    mini_start = alloc(bytes(mini), n_mini)
    root.start = mini_start if n_mini else ENDOFCHAIN
    root.size = len(mini)
    for e in big_streams:
        e.start = alloc(e.data, nsec(e.size))
    fat_start = len(fat)
    for _ in range(n_fat):
        fat.append(FATSECT)
    while len(fat) < n_fat * (SECTOR // 4):
        fat.append(FREESECT)

    # Directory
    dbuf = bytearray()
    for e in order:
        name = e.name.encode("utf-16-le")
        assert len(name) <= 62, e.name
        ent = name + b"\0" * (64 - len(name))
        ent += struct.pack("<HBB", len(name) + 2, e.kind, e.color)
        ent += struct.pack("<III", e.left, e.right, e.child)
        ent += b"\0" * 16 + b"\0" * 4 + b"\0" * 16
        start = e.start if e.kind != 1 else 0
        size = e.size if e.kind != 1 else 0
        ent += struct.pack("<IQ", start, size)
        assert len(ent) == 128
        dbuf += ent
    while len(dbuf) % SECTOR:
        empty = b"\0" * 64 + struct.pack("<HBB", 0, 0, 0) + struct.pack("<III", NOSTREAM, NOSTREAM, NOSTREAM)
        empty += b"\0" * (128 - len(empty))
        dbuf += empty
    for k in range(n_dir):
        sectors[dir_start_placeholder + k] = bytes(dbuf[k * SECTOR:(k + 1) * SECTOR])

    fat_bytes = b"".join(struct.pack("<I", v) for v in fat)
    for k in range(n_fat):
        sectors.append(fat_bytes[k * SECTOR:(k + 1) * SECTOR])

    header = bytearray()
    header += bytes.fromhex("D0CF11E0A1B11AE1") + b"\0" * 16
    header += struct.pack("<HHHHH", 0x3E, 3, 0xFFFE, 9, 6)
    header += b"\0" * 6
    header += struct.pack("<II", 0, n_fat)
    header += struct.pack("<II", dir_start_placeholder if n_dir else ENDOFCHAIN, 0)
    header += struct.pack("<I", CUTOFF)
    header += struct.pack("<II", minifat_start if n_minifat else ENDOFCHAIN, n_minifat)
    header += struct.pack("<II", ENDOFCHAIN, 0)
    difat = [fat_start + k for k in range(n_fat)] + [FREESECT] * (109 - n_fat)
    header += b"".join(struct.pack("<I", v) for v in difat)
    assert len(header) == 512
    return bytes(header) + b"".join(sectors)
