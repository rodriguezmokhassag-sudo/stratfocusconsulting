"""Generation d'un vbaProject.bin (MS-OVBA) a partir de fichiers source VBA.

Le projet est ecrit sans p-code (_VBA_PROJECT version 0xFFFF) : Excel recompile
automatiquement le code source a l'ouverture, quelle que soit sa version.
"""
import random
import struct
import uuid

from cfb import write_cfb

CODEPAGE = 1252
ENC = "cp1252"


# ---------------------------------------------------------------- compression
def _copy_token_help(diff):
    bit_count = 4
    while (1 << bit_count) < diff:
        bit_count += 1
    bit_count = max(bit_count, 4)
    length_mask = 0xFFFF >> bit_count
    max_len = length_mask + 3
    return bit_count, length_mask, max_len


def _compress_chunk(data):
    out = bytearray()
    pos = 0
    n = len(data)
    table = {}
    def remember(p):
        if p + 3 <= n:
            table.setdefault(data[p:p + 3], []).append(p)
    while pos < n:
        flag_pos = len(out)
        out.append(0)
        flag = 0
        for bit in range(8):
            if pos >= n:
                break
            best_len = 0
            best_off = 0
            if pos > 0 and pos + 3 <= n:
                bit_count, _, max_len = _copy_token_help(pos)
                max_off = 1 << (16 - bit_count)
                limit = min(max_len, n - pos)
                cands = table.get(data[pos:pos + 3], [])
                for cand in reversed(cands[-64:]):
                    if pos - cand > max_off:
                        break
                    ln = 3
                    while ln < limit and data[cand + ln] == data[pos + ln]:
                        ln += 1
                    if ln > best_len:
                        best_len = ln
                        best_off = pos - cand
                        if ln == limit:
                            break
            if best_len >= 3:
                bit_count, _, _ = _copy_token_help(pos)
                token = ((best_off - 1) << (16 - bit_count)) | (best_len - 3)
                out += struct.pack("<H", token)
                flag |= 1 << bit
                for p in range(pos, pos + best_len):
                    remember(p)
                pos += best_len
            else:
                out.append(data[pos])
                remember(pos)
                pos += 1
        out[flag_pos] = flag
    return bytes(out)


def compress(data):
    out = bytearray(b"\x01")
    for i in range(0, len(data), 4096):
        chunk = data[i:i + 4096]
        comp = _compress_chunk(chunk)
        if len(comp) > 4096 and len(chunk) == 4096:
            out += struct.pack("<H", 0x3FFF) + chunk
        else:
            out += struct.pack("<H", ((len(comp) + 2 - 3) & 0x0FFF) | 0xB000) + comp
    return bytes(out)


# ------------------------------------------------------------- encryption
def _encrypt(data, project_id):
    seed = random.randint(0, 255)
    version = 2
    proj_key = sum(project_id.encode(ENC)) & 0xFF
    out = bytearray([seed, version ^ seed, proj_key ^ seed])
    unenc1 = proj_key
    enc1 = out[2]
    enc2 = out[1]
    ignored = (seed & 6) // 2

    def push(b):
        nonlocal unenc1, enc1, enc2
        e = b ^ ((enc2 + unenc1) & 0xFF)
        out.append(e)
        enc2 = enc1
        enc1 = e
        unenc1 = b

    for _ in range(ignored):
        push(7)
    for b in struct.pack("<I", len(data)):
        push(b)
    for b in data:
        push(b)
    return out.hex().upper()


# ------------------------------------------------------------------ streams
def _rec(rid, payload):
    return struct.pack("<HI", rid, len(payload)) + payload


def _dir_stream(modules):
    d = bytearray()
    d += _rec(0x0001, struct.pack("<I", 1))  # SYSKIND win32
    d += _rec(0x0002, struct.pack("<I", 0x409))
    d += _rec(0x0014, struct.pack("<I", 0x409))
    d += _rec(0x0003, struct.pack("<H", CODEPAGE))
    d += _rec(0x0004, b"VBAProject")
    d += _rec(0x0005, b"") + _rec(0x0040, b"")
    d += _rec(0x0006, b"") + _rec(0x003D, b"")
    d += _rec(0x0007, struct.pack("<I", 0))
    d += _rec(0x0008, struct.pack("<I", 0))
    d += struct.pack("<HIIH", 0x0009, 4, 1, 0)
    d += _rec(0x000C, b"") + _rec(0x003C, b"")
    # Reference stdole
    libid = b"*\\G{00020430-0000-0000-C000-000000000046}#2.0#0#C:\\Windows\\System32\\stdole2.tlb#OLE Automation"
    d += _rec(0x0016, b"stdole") + _rec(0x003E, "stdole".encode("utf-16-le"))
    reg = struct.pack("<I", len(libid)) + libid + struct.pack("<IH", 0, 0)
    d += _rec(0x000D, reg)
    d += _rec(0x000F, struct.pack("<H", len(modules)))
    d += _rec(0x0013, struct.pack("<H", 0xFFFF))
    for name, kind, _src in modules:
        bname = name.encode(ENC)
        uname = name.encode("utf-16-le")
        d += _rec(0x0019, bname) + _rec(0x0047, uname)
        d += _rec(0x001A, bname) + _rec(0x0032, uname)
        d += _rec(0x001C, b"") + _rec(0x0048, b"")
        d += _rec(0x0031, struct.pack("<I", 0))
        d += _rec(0x001E, struct.pack("<I", 0))
        d += _rec(0x002C, struct.pack("<H", 0xFFFF))
        d += struct.pack("<HI", 0x0021 if kind == "std" else 0x0022, 0)
        d += struct.pack("<HI", 0x002B, 0)
    d += struct.pack("<HI", 0x0010, 0)
    return bytes(d)


def _project_stream(modules, project_id):
    lines = ['ID="%s"' % project_id]
    for name, kind, _ in modules:
        if kind == "doc":
            lines.append("Document=%s/&H00000000" % name)
        elif kind == "cls":
            lines.append("Class=%s" % name)
        else:
            lines.append("Module=%s" % name)
    lines += [
        'Name="VBAProject"',
        'HelpContextID="0"',
        'VersionCompatible32="393222000"',
        'CMG="%s"' % _encrypt(struct.pack("<I", 0), project_id),
        'DPB="%s"' % _encrypt(b"\x00", project_id),
        'GC="%s"' % _encrypt(b"\xFF", project_id),
        "",
        "[Host Extender Info]",
        "&H00000001={3832D640-CF90-11CF-8E43-00A0C911005A};VBE;&H00000000",
        "",
        "[Workspace]",
    ]
    for name, _, _ in modules:
        lines.append("%s=0, 0, 0, 0, C" % name)
    return ("\r\n".join(lines) + "\r\n").encode(ENC)


def _projectwm(modules):
    out = bytearray()
    for name, _, _ in modules:
        out += name.encode(ENC) + b"\0" + name.encode("utf-16-le") + b"\0\0"
    out += b"\0\0"
    return bytes(out)


DOC_ATTRS = {
    "workbook": "0{00020819-0000-0000-C000-000000000046}",
    "sheet": "0{00020820-0000-0000-C000-000000000046}",
}


def build_vba_project(modules):
    """modules : liste de (nom, type, source) ; type = std | cls | doc.

    Pour les modules document, la source est le code sans en-tete d'attributs ;
    pour std/cls la source peut contenir ses propres lignes Attribute.
    """
    project_id = "{%s}" % str(uuid.uuid4()).upper()
    streams = {}
    for name, kind, src in modules:
        src = src.replace("\r\n", "\n").replace("\n", "\r\n")
        streams[name] = compress(src.encode(ENC))
    vba = {"_VBA_PROJECT": b"\xCC\x61\xFF\xFF\x00\x00\x00", "dir": compress(_dir_stream(modules))}
    vba.update(streams)
    tree = {
        "PROJECT": _project_stream(modules, project_id),
        "PROJECTwm": _projectwm(modules),
        "VBA": vba,
    }
    return write_cfb(tree)


def doc_module_source(name, base, code):
    head = [
        'Attribute VB_Name = "%s"' % name,
        'Attribute VB_Base = "%s"' % DOC_ATTRS[base],
        "Attribute VB_GlobalNameSpace = False",
        "Attribute VB_Creatable = False",
        "Attribute VB_PredeclaredId = True",
        "Attribute VB_Exposed = True",
        "Attribute VB_TemplateDerived = False",
        "Attribute VB_Customizable = True",
    ]
    return "\r\n".join(head) + "\r\n" + code


def std_module_source(name, code):
    lines = code.replace("\r\n", "\n").split("\n")
    lines = [l for l in lines if not l.startswith("Attribute VB_Name")]
    return 'Attribute VB_Name = "%s"\r\n' % name + "\r\n".join(lines)
