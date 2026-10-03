"""Nita mayonnaise – 20 s motion-design spot with animated LCC outro.
usage: python3 render.py W H start end out.mp4   (frames [start,end) at 30 fps)
"""
import sys, math, subprocess, functools
import numpy as np, cv2
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

W, H = int(sys.argv[1]), int(sys.argv[2])
FPS = 30
PORTRAIT = H > W
U = min(W, H) / 2160.0          # unit scale (1.0 at 4K short side)
CUT = 60 / 108 * 4 * 1.5          # 3.333 s, bar-aligned with the music
T1, T2, T3, T4 = CUT, 2 * CUT, 3 * CUT, 4 * CUT   # scene boundaries; outro from T4 to 20 s
DUR = 20.0
XF = 0.35                         # crossfade length

FONT_B = 'fonts/Poppins-ExtraBold.ttf'
FONT_S = 'fonts/Poppins-SemiBold.ttf'
ARIAL_B = '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf'
NITA_BLUE = (32, 52, 170)
LCC_NAVY = (44, 47, 118)
CREAM = (246, 238, 208)

def clamp(x, a=0.0, b=1.0): return max(a, min(b, x))
def lin(t, a, b): return clamp((t - a) / (b - a)) if b > a else float(t >= a)
def eio(x): return x * x * (3 - 2 * x)
def eout(x): return 1 - (1 - x) ** 3
def back(x, s=1.7): x -= 1; return x * x * ((s + 1) * x + s) + 1
def elastic(x):
    if x <= 0: return 0.0
    if x >= 1: return 1.0
    return 2 ** (-10 * x) * math.sin((x * 10 - 0.75) * (2 * math.pi / 3)) + 1

# ---------------------------------------------------------------- assets
JAR = Image.open('assets/jar_clean.png').convert('RGBA')
JW, JH = JAR.size
LID_Y = 282
LID = JAR.crop((0, 0, JW, LID_Y))
BODY = JAR.copy(); ImageDraw.Draw(BODY).rectangle((0, 0, JW, LID_Y - 1), fill=(0, 0, 0, 0))

def make_mouth():
    """Open jar mouth (glass rim + creamy surface) drawn in jar-asset coordinates."""
    im = Image.new('RGBA', (JW, 420), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    cx, cy, rx, ry = 1036, 300, 880, 105
    d.ellipse((cx - rx, cy - ry, cx + rx, cy + ry), fill=(236, 236, 232, 255))
    d.ellipse((cx - rx + 40, cy - ry + 10, cx + rx - 40, cy + ry - 6), fill=(226, 214, 176, 255))
    d.ellipse((cx - rx + 70, cy - ry + 20, cx + rx - 70, cy + ry - 4), fill=CREAM + (255,))
    # soft swirl ridges on the cream
    for k, (w, o) in enumerate([(0.75, 0), (0.5, 12), (0.28, 22)]):
        d.arc((cx - rx * w, cy - ry * w + o, cx + rx * w, cy + ry * w + o), 200, 340, fill=(214, 200, 160, 255), width=10)
        d.arc((cx - rx * w, cy - ry * w + o - 6, cx + rx * w, cy + ry * w + o - 6), 205, 330, fill=(255, 252, 238, 255), width=7)
    d.arc((cx - rx + 8, cy - ry + 2, cx + rx - 8, cy + ry - 2), 190, 350, fill=(255, 255, 255, 200), width=10)
    return im.filter(ImageFilter.GaussianBlur(2))
MOUTH = make_mouth()

MAP = Image.open('assets/lcc_map.png').convert('RGBA')   # 1984x2000, crop of logo [40:540, 450:946] x4

def layer_from_map(boxes, keep):
    """Return (layer, centre) with only the pixels in boxes (keep=True) or outside them."""
    a = np.array(MAP); m = np.zeros(a.shape[:2], bool)
    for x0, y0, x1, y1 in boxes: m[y0:y1, x0:x1] = True
    if not keep: m = ~m
    out = a.copy(); out[..., 3] = (out[..., 3] * m).astype(np.uint8)
    return Image.fromarray(out)

# small "L C C" letters (map-asset px) and food icons
SMALL = [(880, 20, 1180, 380), (1320, 140, 1640, 470), (1590, 500, 1910, 820)]
ICONS = [(520, 470, 1090, 790), (760, 900, 1250, 1230), (1080, 1360, 1880, 1890)]
MAP_BASE = layer_from_map(SMALL, keep=False)
SMALL_L = [layer_from_map([b], True).crop(b) for b in SMALL]
def icon_layer(b):
    a = np.array(MAP.crop(b)).astype(int)
    navy = (abs(a[..., 0] - 44) < 40) & (abs(a[..., 1] - 47) < 40) & (abs(a[..., 2] - 118) < 45)
    m = (~navy & (a[..., 3] > 100)).astype(np.uint8) * 255
    m = cv2.dilate(m, np.ones((7, 7), np.uint8)); m = cv2.GaussianBlur(m, (0, 0), 1.5)
    a[..., 3] = np.minimum(a[..., 3], m); return Image.fromarray(a.astype(np.uint8))
ICON_L = [icon_layer(b) for b in ICONS]

@functools.lru_cache(None)
def font(path, size): return ImageFont.truetype(path, max(8, int(size)))

@functools.lru_cache(None)
def text_img(txt, path, size, color, shadow=0, stroke=0, stroke_col=(0, 0, 0)):
    f = font(path, size)
    l, t, r, b = f.getbbox(txt, stroke_width=stroke)
    pad = int(size * 0.3) + shadow * 2
    im = Image.new('RGBA', (r - l + 2 * pad, b - t + 2 * pad), (0, 0, 0, 0))
    if shadow:
        sh = Image.new('RGBA', im.size, (0, 0, 0, 0))
        ImageDraw.Draw(sh).text((pad - l, pad - t + shadow // 2), txt, font=f, fill=(0, 0, 0, 150), stroke_width=stroke, stroke_fill=(0, 0, 0, 150))
        im = Image.alpha_composite(im, sh.filter(ImageFilter.GaussianBlur(shadow)))
    ImageDraw.Draw(im).text((pad - l, pad - t), txt, font=f, fill=color, stroke_width=stroke, stroke_fill=stroke_col)
    return im

def fitted_font(txt, path, width):
    s = 100; w = font(path, s).getlength(txt); return s * width / w

# ---------------------------------------------------------------- compositing helpers
def paste(canvas, im, cx, cy, scale=1.0, rot=0.0, alpha=1.0, anchor='c'):
    if alpha <= 0.003 or scale <= 0.002: return
    w, h = max(1, int(im.width * scale)), max(1, int(im.height * scale))
    if (w, h) != im.size:
        im = im.resize((w, h), Image.BICUBIC, reducing_gap=2.0 if scale < 0.5 else None)
    if rot: im = im.rotate(rot, resample=Image.BICUBIC, expand=True)
    if alpha < 1:
        a = im.getchannel('A').point(lambda v: int(v * alpha)); im = im.copy(); im.putalpha(a)
    x = int(cx - im.width / 2)
    y = int(cy - im.height / 2) if anchor == 'c' else int(cy - im.height)
    # clip to canvas for speed
    x0, y0 = max(0, x), max(0, y); x1, y1 = min(canvas.width, x + im.width), min(canvas.height, y + im.height)
    if x1 <= x0 or y1 <= y0: return
    canvas.alpha_composite(im.crop((x0 - x, y0 - y, x1 - x, y1 - y)), (x0, y0))

def np_img(a): return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8)).convert('RGBA')

def noise(h, w, cells_y, cells_x, seed):
    r = np.random.default_rng(seed).random((cells_y, cells_x)).astype(np.float32)
    return cv2.resize(r, (w, h), interpolation=cv2.INTER_CUBIC)

def vignette(h, w, k=0.55):
    y, x = np.mgrid[0:h, 0:w].astype(np.float32)
    d = np.sqrt(((x - w / 2) / (w / 2)) ** 2 + ((y - h / 2) / (h / 2)) ** 2) / math.sqrt(2)
    return 1 - k * d ** 2

def wood(h, w, seed, plank=None, vertical_dof=False):
    n1 = noise(h, w, 12, 6, seed) * 10 + noise(h, w, 60, 8, seed + 1) * 1.5
    y = np.mgrid[0:h, 0:w][0].astype(np.float32)
    g = np.sin(y / (h / 90.0) + n1 * 2.2)
    g2 = np.sin(y / (h / 400.0) + n1 * 6) * 0.3
    tone = 0.5 + 0.28 * g + 0.12 * g2 + (noise(h, w, 4, 3, seed + 5) - 0.5) * 0.5
    dark, light = np.array([62, 38, 22], np.float32), np.array([150, 99, 60], np.float32)
    img = dark + (light - dark) * np.clip(tone, 0, 1)[..., None]
    if plank:
        for yy in np.arange(plank, h, plank):
            yy = int(yy); img[max(0, yy - 3):yy + 3] *= 0.45
    img *= (0.92 + 0.08 * np.random.default_rng(seed).random((h, w, 1))).astype(np.float32)
    return img

# ---------------------------------------------------------------- static backgrounds (cached)
@functools.lru_cache(None)
def bg_studio():
    y = np.linspace(0, 1, H, dtype=np.float32)[:, None, None]
    top, bot = np.array([196, 202, 212], np.float32), np.array([118, 126, 142], np.float32)
    img = top + (bot - top) * y
    img = img * np.ones((1, W, 1), np.float32)
    img *= vignette(H, W, 0.45)[..., None]
    # soft key light behind
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    glow = np.exp(-(((xx - W * 0.62) / (W * 0.35)) ** 2 + ((yy - H * 0.35) / (H * 0.45)) ** 2))
    img += glow[..., None] * 40
    return np_img(img)

@functools.lru_cache(None)
def bg_topdown():
    img = wood(H, W, 11, plank=int(max(W, H) / 5.5))
    img = img * vignette(H, W, 0.7)[..., None]
    return np_img(img)

@functools.lru_cache(None)
def bg_table():
    """Wall + wooden table seen at eye level, background softly out of focus. Rendered 1.15x wider for the dolly."""
    w = int(W * 1.15); hz = int(H * (0.58 if not PORTRAIT else 0.62))
    wall = np.zeros((hz, w, 3), np.float32)
    yy, xx = np.mgrid[0:hz, 0:w].astype(np.float32)
    wall[:] = np.array([150, 142, 132], np.float32)
    wall += (np.exp(-(((xx - w * 0.7) / (w * 0.3)) ** 2 + ((yy - hz * 0.3) / (hz * 0.6)) ** 2)) * 60)[..., None]
    wall += (noise(hz, w, 6, 10, 3)[..., None] - 0.5) * 25
    table = wood(H - hz, w, 21)
    # perspective: compress the far part of the table
    th = H - hz; src_y = (np.linspace(0, 1, th) ** 1.8 * (th - 1)).astype(np.float32)
    mapx = np.tile(np.arange(w, dtype=np.float32), (th, 1)); mapy = np.tile(src_y[:, None], (1, w))
    table = cv2.remap(table, mapx, mapy, cv2.INTER_LINEAR)
    table *= np.linspace(0.75, 1.05, th, dtype=np.float32)[:, None, None]
    img = np.concatenate([wall, table], 0)
    img[hz - 6:hz + 2] *= 0.6
    blur = cv2.GaussianBlur(img, (0, 0), 18 * U)
    m = np.clip((np.arange(H, dtype=np.float32) - (hz - 60 * U)) / (H * 0.35), 0, 1)[:, None, None]
    img = blur * (1 - m) + img * m        # far = blurred, near = sharp
    img *= vignette(H, w, 0.35)[..., None]
    return np_img(img), hz

@functools.lru_cache(None)
def bg_brand():
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    d = np.sqrt(((xx - W / 2) / (max(W, H) * 0.6)) ** 2 + ((yy - H * 0.48) / (max(W, H) * 0.6)) ** 2)
    c0, c1 = np.array([58, 96, 220], np.float32), np.array([8, 18, 70], np.float32)
    img = c0 + (c1 - c0) * np.clip(d, 0, 1)[..., None] ** 0.8
    return np_img(img)

@functools.lru_cache(None)
def bokeh_set():
    rng = np.random.default_rng(5); out = []
    for i in range(26):
        r = rng.uniform(30, 140) * U
        out.append((rng.uniform(0, 1), rng.uniform(0, 1), r, rng.uniform(0.05, 0.22), rng.uniform(-1, 1)))
    return out

@functools.lru_cache(None)
def bokeh_disc(r):
    s = int(r * 2 + 20); im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    ImageDraw.Draw(im).ellipse((10, 10, s - 10, s - 10), fill=(255, 255, 255, 255))
    return im.filter(ImageFilter.GaussianBlur(r * 0.12 + 2))

@functools.lru_cache(None)
def shadow_img():
    im = Image.new('RGBA', (1400, 300), (0, 0, 0, 0))
    ImageDraw.Draw(im).ellipse((150, 90, 1250, 210), fill=(0, 0, 0, 170))
    return im.filter(ImageFilter.GaussianBlur(40))

def jar_on(canvas, cx, base_y, scale, alpha=1.0, lid=True, sweep=None):
    """Draw the jar standing with its bottom at base_y."""
    paste(canvas, shadow_img(), cx, base_y + 10 * scale, scale * JW / 1100 * 1.08, alpha=alpha * 0.9)
    img = JAR if lid else BODY
    if sweep is not None:
        img = with_sweep(img, sweep)
    paste(canvas, img, cx, base_y + 8 * scale, scale, alpha=alpha, anchor='b')

@functools.lru_cache(None)
def sweep_band():
    w, h = JW, JH; x = np.arange(w + h, dtype=np.float32)
    return x
def with_sweep(img, p):
    """Diagonal light sweep across the glass, p in [0,1]."""
    a = np.array(img); h, w = a.shape[:2]
    yy, xx = np.mgrid[0:h:4, 0:w:4].astype(np.float32)
    pos = (xx + yy * 0.45) / (w + h * 0.45)
    band = np.exp(-((pos - (p * 1.4 - 0.2)) / 0.05) ** 2) * 0.55
    band = cv2.resize(band, (w, h))
    al = a[..., 3:4].astype(np.float32) / 255
    rgb = a[..., :3].astype(np.float32); rgb = rgb + (255 - rgb) * band[..., None] * al
    a[..., :3] = rgb.astype(np.uint8); return Image.fromarray(a)

def title(canvas, txt, cx, cy, size, t, t0, dur=0.5, color=(255, 255, 255, 255), shadow=None, stroke=0, stroke_col=(0, 0, 0)):
    p = lin(t, t0, t0 + dur)
    if p <= 0: return
    im = text_img(txt, FONT_B, int(size), color, shadow if shadow is not None else int(size * 0.08), stroke, stroke_col)
    paste(canvas, im, cx, cy + (1 - eout(p)) * size * 0.6, 0.85 + 0.15 * back(p), alpha=eout(p))

# ---------------------------------------------------------------- scenes  (t = local time in s)
def scene1(t):
    """Close-up on the lid: push-in, the lid twists and lifts off, revealing the cream."""
    c = bg_studio().copy()
    s = (0.95 if not PORTRAIT else 0.86) * (W if PORTRAIT else H * 1.05) / JW * (1 + 0.06 * eio(lin(t, 0, CUT)))
    cx = W * (0.5 if PORTRAIT else 0.47)
    top = H * (0.30 if not PORTRAIT else 0.36) - 40 * s * eio(lin(t, 0, CUT))   # where the lid sits
    cy_body = top + JH * s / 2
    paste(c, shadow_img(), cx, top + JH * s, s * JW / 1100)
    paste(c, BODY, cx, cy_body, s)
    o = lin(t, 1.15, 2.1)
    if o > 0: paste(c, MOUTH, cx, top + MOUTH.height * s / 2, s)
    # lid: twist (small wobble) 0.6-1.15 s, then lift & fly up-left
    tw = lin(t, 0.55, 1.15); wob = math.sin(tw * math.pi * 3) * 4 * (1 - tw) if 0 < tw < 1 else 0
    up = eio(o) * (H * 0.9); lx = cx - eio(o) * W * 0.12
    paste(c, LID, lx, top + LID_Y * s / 2 - up, s * (1 + 0.04 * eio(o)), rot=wob + 18 * eio(o))
    title(c, 'NITA', W * (0.82 if not PORTRAIT else 0.5), H * (0.2 if not PORTRAIT else 0.13), 150 * U, t, 1.9, 0.6, NITA_BLUE + (255,), shadow=0)
    title(c, 'Mayonnaise', W * (0.82 if not PORTRAIT else 0.5), H * (0.2 if not PORTRAIT else 0.13) + 150 * U, 80 * U, t, 2.1, 0.6, (40, 44, 60, 255), shadow=0)
    return c

@functools.lru_cache(None)
def topdown_static(R):
    """Top view inside the open jar: glass ring and cream surface (size 2R+pad)."""
    S = int(2 * R + 80); c = S / 2
    yy, xx = np.mgrid[0:S, 0:S].astype(np.float32); d = np.sqrt((xx - c) ** 2 + (yy - c) ** 2)
    img = np.zeros((S, S, 4), np.float32)
    # glass ring
    ring = (d <= R) & (d > R * 0.86)
    gl = 205 + 45 * np.cos(np.arctan2(yy - c, xx - c) * 2 + 0.8)
    img[ring, :3] = np.stack([gl, gl, gl * 1.02], -1)[ring]
    img[ring, 3] = 235
    # cream
    cr = d <= R * 0.86
    sh = 1 - 0.18 * (d / (R * 0.86)) ** 3 + 0.06 * ((c - xx) + (c - yy)) / R
    cream = np.array(CREAM, np.float32) * sh[..., None]
    img[cr, :3] = cream[cr]; img[cr, 3] = 255
    a = np.clip(img, 0, 255).astype(np.uint8)
    a[..., 3] = cv2.GaussianBlur(a[..., 3], (0, 0), 1.5)
    im = Image.fromarray(a)
    d2 = ImageDraw.Draw(im)
    d2.arc((c - R + 10, c - R + 10, c + R - 10, c + R - 10), 200, 290, fill=(255, 255, 255, 230), width=int(R * 0.03))
    d2.ellipse((c - R * 0.86, c - R * 0.86, c + R * 0.86, c + R * 0.86), outline=(200, 186, 150, 255), width=int(R * 0.02))
    # outer drop shadow
    sh = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse((c - R + 20, c - R + 40, c + R + 20, c + R + 40), fill=(0, 0, 0, 140))
    sh = sh.filter(ImageFilter.GaussianBlur(R * 0.06))
    return Image.alpha_composite(sh, im)

@functools.lru_cache(None)
def swirl(R):
    S = int(2 * R); c = S / 2; im = Image.new('RGBA', (S, S), (0, 0, 0, 0)); d = ImageDraw.Draw(im)
    turns = 3.2; pts = []
    for i in range(1400):
        th = i / 1400 * turns * 2 * math.pi; r = R * 0.8 * (1 - i / 1400) + R * 0.04
        pts.append((c + r * math.cos(th), c + r * math.sin(th)))
    w = int(R * 0.05)
    d.line([(x + w * 0.35, y + w * 0.35) for x, y in pts], fill=(196, 178, 132, 200), width=w, joint='curve')
    d.line(pts, fill=(255, 251, 236, 255), width=int(w * 0.7), joint='curve')
    return im.filter(ImageFilter.GaussianBlur(R * 0.008))

def scene2(t):
    """Top-down into the open jar: the cream swirl turns; text 'Crémeuse à souhait'."""
    c = bg_topdown().copy()
    R = int((0.62 if not PORTRAIT else 0.42) * min(H, W) * (1 if not PORTRAIT else 2.0) / 2 * (1.0 if not PORTRAIT else 1.0))
    R = int(min(H, W) * (0.46 if not PORTRAIT else 0.44))
    z = 1 + 0.10 * eio(lin(t, 0, CUT))
    cx, cy = (W * 0.36, H * 0.5) if not PORTRAIT else (W * 0.5, H * 0.56)
    paste(c, topdown_static(R), cx, cy, z)
    paste(c, swirl(R), cx, cy, z, rot=-t * 40 - 30)
    tx, ty = (W * 0.76, H * 0.43) if not PORTRAIT else (W * 0.5, H * 0.16)
    title(c, 'Crémeuse', tx, ty, 190 * U, t, 0.45, 0.55)
    title(c, 'à souhait', tx, ty + 210 * U, 150 * U, t, 0.7, 0.55, CREAM + (255,))
    return c

def scene3(t):
    """Eye-level shot on the wooden table: slow lateral dolly with parallax."""
    bg, hz = bg_table()
    p = eio(lin(t, 0, CUT))
    off = int((bg.width - W) * (0.15 + 0.7 * p))
    c = bg.crop((off, 0, off + W, H)).copy()
    s = (H * 0.72 if not PORTRAIT else H * 0.5) / JH
    base = hz + (H - hz) * (0.55 if not PORTRAIT else 0.42)
    cx = (W * 0.36 if not PORTRAIT else W * 0.5) - (p - 0.5) * W * 0.14
    jar_on(c, cx, base, s)
    tx, ty = (W * 0.73, H * 0.36) if not PORTRAIT else (W * 0.5, H * 0.15)
    title(c, 'Onctueuse', tx, ty, 170 * U, t, 0.35, 0.55)
    title(c, '& savoureuse', tx, ty + 190 * U, 130 * U, t, 0.6, 0.55, CREAM + (255,))
    title(c, 'pour toutes vos recettes', tx, ty + 350 * U, 78 * U, t, 0.95, 0.55, (255, 255, 255, 235))
    return c

def scene4(t):
    """Hero packshot on brand blue + slogan."""
    c = bg_brand().copy()
    for i, (bx, by, r, a, sp) in enumerate(bokeh_set()):
        x = (bx * W + sp * t * 60 * U) % W; y = (by * H - t * 25 * U * (1 + abs(sp))) % H
        paste(c, bokeh_disc(int(r)), x, y, 1.0, alpha=a)
    p = lin(t, 0, 0.9)
    s = (H * 0.70 if not PORTRAIT else H * 0.46) / JH * (0.9 + 0.1 * back(p)) * (1 + 0.03 * lin(t, 0.9, CUT))
    cx = W * (0.32 if not PORTRAIT else 0.5); base = H * (0.92 if not PORTRAIT else 0.86)
    jar_on(c, cx, base, s, alpha=eout(p), sweep=lin(t, 1.0, 2.4))
    if not PORTRAIT:
        title(c, 'Il suffit', W * 0.70, H * 0.36, 210 * U, t, 0.6, 0.5)
        title(c, 'de goûter !', W * 0.70, H * 0.36 + 230 * U, 210 * U, t, 0.85, 0.5, (255, 214, 90, 255))
        title(c, 'Mayonnaise NITA', W * 0.70, H * 0.36 + 470 * U, 90 * U, t, 1.3, 0.5, (230, 236, 255, 255))
    else:
        title(c, 'Il suffit', W * 0.5, H * 0.10, 200 * U, t, 0.6, 0.5)
        title(c, 'de goûter !', W * 0.5, H * 0.10 + 220 * U, 200 * U, t, 0.85, 0.5, (255, 214, 90, 255))
        title(c, 'Mayonnaise NITA', W * 0.5, H * 0.10 + 420 * U, 90 * U, t, 1.3, 0.5, (230, 236, 255, 255))
    return c

# ---- LCC outro: logo rebuilt in its original layout (logo units = px of the 1419x1419 source)
@functools.lru_cache(None)
def big_letter(ch, size):
    return text_img(ch, ARIAL_B, size, LCC_NAVY + (255,), 0)

LETTERS = [('L', 171, 392), ('.', 437, 496), ('C', 550, 822), ('.', 877, 936), ('C', 990, 1262)]
CONTACTS = ['Tél : (+242) 04 444 06 60 / 04 444 06 11', '04 444 06 30 B.P. 1159 Pointe-Noire', 'République du Congo']
CONTACT_BOX = [(1089, 1137), (1151, 1188), (1211, 1259)]

def scene5(t):
    c = Image.new('RGBA', (W, H), (255, 255, 255, 255))
    # logo occupies source rows 40..1260 (1220 units), cols 160..1270
    k = min(H * 0.86 / 1220, W * 0.9 / 1110) * (1 + 0.025 * lin(t, 3.6, DUR - T4))
    ox = W / 2 - 715 * k; oy = H / 2 - 650 * k
    X = lambda u: ox + u * k; Y = lambda v: oy + v * k
    # soft radial backdrop
    # Africa map (map asset = source crop [40:540, 450:946] scaled x4)
    pm = lin(t, 0.15, 1.05); ms = k / 4
    mx, my = X(450 + 496 / 2), Y(40 + 500 / 2)
    paste(c, MAP_BASE, mx, my, ms * elastic(pm), rot=(1 - eout(pm)) * -25, alpha=clamp(pm * 4))
    for i, (b, im) in enumerate(zip(ICONS, ICON_L)):
        q = lin(t, 0.95 + 0.18 * i, 1.45 + 0.18 * i)
        if 0 < q < 1:
            sc = 1 + 0.3 * math.sin(q * math.pi)
            paste(c, im, X(450 + (b[0] + b[2]) / 8), Y(40 + (b[1] + b[3]) / 8), ms * sc)
    for i, (b, im) in enumerate(zip(SMALL, SMALL_L)):
        q = lin(t, 1.0 + 0.14 * i, 1.6 + 0.14 * i)
        if q > 0:
            dy = (1 - elastic(q)) * -300 * k
            paste(c, im, X(450 + (b[0] + b[2]) / 8), Y(40 + (b[1] + b[3]) / 8) + dy, ms, alpha=clamp(q * 3))
    # big L.C.C – each glyph rises from behind a baseline mask
    size = int(392 * k)
    for i, (ch, x0, x1) in enumerate(LETTERS):
        q = lin(t, 1.45 + 0.1 * i, 2.05 + 0.1 * i)
        if q <= 0: continue
        g = big_letter(ch, size)
        bb = g.getbbox(); g = g.crop(bb)
        target_h = (847 - 566) * k if ch != '.' else g.height
        gs = target_h / g.height if ch != '.' else (x1 - x0) * k / g.width
        gw, gh = g.width * gs, g.height * gs
        cx = X(x0) + gw / 2; cy = Y(848) - gh / 2 + (1 - back(q, 1.4)) * gh * 0.9
        layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
        paste(layer, g, cx, cy, gs, alpha=clamp(q * 2.5))
        mask_bottom = int(Y(852))
        if mask_bottom < H:
            ImageDraw.Draw(layer).rectangle((0, mask_bottom, W, H), fill=(0, 0, 0, 0))
        c.alpha_composite(layer)
    # tagline
    q = lin(t, 2.25, 2.85)
    if q > 0:
        fs = fitted_font('La Congolaise de Congélation', ARIAL_B, (1237 - 173) * k)
        im = text_img('La Congolaise de Congélation', ARIAL_B, int(fs), (0, 0, 0, 255), 0)
        paste(c, im, X(705), Y(900) + (1 - eout(q)) * 60 * k, 1.0, alpha=eout(q))
    # divider line drawn from the centre
    q = lin(t, 2.7, 3.3)
    if q > 0:
        half = eout(q) * 330 * k; yl = Y(1012)
        ImageDraw.Draw(c).rounded_rectangle((X(705) - half, yl - 5 * k, X(705) + half, yl + 5 * k), radius=int(5 * k), fill=LCC_NAVY + (255,))
        ImageDraw.Draw(c).rounded_rectangle((X(705) - half * 0.35, yl - 5 * k, X(705) + half * 0.35, yl + 5 * k), radius=int(5 * k), fill=(232, 160, 40, 255))
    for i, (line, (a, b)) in enumerate(zip(CONTACTS, CONTACT_BOX)):
        q = lin(t, 3.0 + 0.2 * i, 3.55 + 0.2 * i)
        if q <= 0: continue
        fs = 52 * k * 1.0
        im = text_img(line, ARIAL_B, int(fs), (0, 0, 0, 255), 0)
        paste(c, im, X(712), Y((a + b) / 2) + (1 - eout(q)) * 40 * k, 1.0, alpha=eout(q))
    # light sweep over the big letters at the end
    q = lin(t, 4.2, 5.2)
    if 0 < q < 1:
        a = np.array(c).astype(np.float32)
        y0, y1 = int(Y(560)), int(Y(850)); yy, xx = np.mgrid[y0:y1, 0:W].astype(np.float32)
        pos = X(150) + q * (X(1300) - X(150)) - (yy - y0) * 0.4
        band = np.exp(-((xx - pos) / (60 * k)) ** 2)[..., None]
        reg = a[y0:y1, :, :3]; navy = (reg.sum(-1, keepdims=True) < 300)
        a[y0:y1, :, :3] = reg + (np.array([150, 170, 255]) - reg) * band * 0.55 * navy
        c = Image.fromarray(a.astype(np.uint8))
    return c

SCENES = [(0, T1, scene1), (T1, T2, scene2), (T2, T3, scene3), (T3, T4, scene4), (T4, DUR + 1, scene5)]

def frame(t):
    for i, (a, b, fn) in enumerate(SCENES):
        if a <= t < b:
            img = fn(t - a)
            if i + 1 < len(SCENES) and t > b - XF:      # transition into next scene
                p = eio(lin(t, b - XF, b))
                nxt = SCENES[i + 1][2](t - b + XF * 0)  # next scene at its t<=0 state
                if i + 1 == 4:                          # flash to white for the outro
                    img = Image.blend(img, Image.new('RGBA', (W, H), (255, 255, 255, 255)), p)
                else:
                    z = 1 + 0.08 * p
                    big = img.resize((int(W * z), int(H * z)), Image.BILINEAR)
                    img = big.crop(((big.width - W) // 2, (big.height - H) // 2, (big.width - W) // 2 + W, (big.height - H) // 2 + H))
                    img = Image.blend(img, nxt, p)
            return img.convert('RGB')

if __name__ == '__main__':
    if sys.argv[3] == 'still':
        for t in map(float, sys.argv[4].split(',')):
            frame(t).save(f'still_{W}x{H}_{t:05.2f}.jpg', quality=90)
        sys.exit()
    f0, f1, out = int(sys.argv[3]), int(sys.argv[4]), sys.argv[5]
    ff = subprocess.Popen(['ffmpeg', '-v', 'error', '-y', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-',
                           '-c:v', 'libx264', '-preset', 'medium', '-crf', '16', '-pix_fmt', 'yuv420p', '-profile:v', 'high', '-level', '5.1',
                           '-x264-params', 'keyint=30:min-keyint=30:scenecut=0', '-threads', '2', out], stdin=subprocess.PIPE)
    for f in range(f0, f1):
        ff.stdin.write(frame(f / FPS).tobytes())
        if f % 30 == 0: print(out, f, flush=True)
    ff.stdin.close(); ff.wait()
