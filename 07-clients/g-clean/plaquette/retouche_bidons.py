import sys, numpy as np
from PIL import Image, ImageDraw, ImageFilter
W = sys.argv[1]
A = np.asarray(Image.open(W+'/src.png').convert('RGB')).astype(np.float32)
H, Wd, _ = A.shape

def redmask(a):
    r,g,b = a[...,0],a[...,1],a[...,2]
    return (r>150)&(r-g>60)&(r-b>50)

RED = redmask(A)
# dilate red mask a bit
def dilate(m, k=2):
    out = m.copy()
    for dy in range(-k,k+1):
        for dx in range(-k,k+1):
            out |= np.roll(np.roll(m,dy,0),dx,1)
    return out
RED = dilate(RED,2)
_r,_g=A[...,0],A[...,1]
REDBG = dilate(RED|(_r-_g>10),3)
REDBG[:108]=False; REDBG[578:]=False
def gblur(a, sig):
    r=int(sig*3); k=np.exp(-0.5*(np.arange(-r,r+1)/sig)**2); k/=k.sum()
    pad=np.pad(a,[(r,r),(r,r)]+[(0,0)]*(a.ndim-2),mode='edge')
    t=np.apply_along_axis(lambda v:np.convolve(v,k,'valid'),0,pad)
    return np.apply_along_axis(lambda v:np.convolve(v,k,'valid'),1,t)
# column-wise inpaint of red strokes -> A_clean
AC = A.copy()
for x in range(Wd):
    col = REDBG[:,x]
    if not col.any(): continue
    y=0
    while y<H:
        if col[y]:
            y0=y
            while y<H and col[y]: y+=1
            a0 = AC[y0-1,x] if y0>0 else AC[y,x]
            a1 = AC[y,x] if y<H else a0
            n=y-y0+1
            for k in range(y0,y):
                t=(k-y0+1)/n
                AC[k,x]=a0*(1-t)+a1*t
        else: y+=1
valid=(~REDBG).astype(np.float32)
num=np.zeros_like(A); 
for sig in (3,6,12,24):
    num = np.dstack([gblur(AC[...,c]*valid,sig) for c in range(3)])
    den = gblur(valid,sig)[...,None]
    est = num/np.maximum(den,1e-4)
    ok = (den[...,0]>0.15)&REDBG
    AC[ok]=est[ok]
    valid = np.maximum(valid, ok.astype(np.float32)); A_=None

CARD_TOP, BAND = 137, 580
NEW_H_ZONE = 268                      # new coloured zone height (was 443)
D = (BAND-CARD_TOP) - NEW_H_ZONE      # rows removed
NEW_BAND = CARD_TOP + NEW_H_ZONE
cards = [  # x0, x1, bidon_left, bidon_bottom
    (10,177,25,480),(194,362,222,480),(379,546,398,480),
    (629,797,651,482),(814,981,839,480),(998,1165,1015,482)]

def feats(x,y):
    x=x/100.0; y=y/100.0
    return np.stack([np.ones_like(x),x,y,x*x,y*y,x*y,y**3],-1)

def fit_card(x0,x1,bl,bb):
    ys,xs = np.mgrid[CARD_TOP+3:BAND-2, x0+3:x1-3]
    m = ~RED[ys,xs]
    m &= ~((xs>=bl-6)&(xs<=bl+130)&(ys>=284)&(ys<=bb+8))
    F = feats(xs[m].astype(float),ys[m].astype(float))
    coef,*_ = np.linalg.lstsq(F, A[ys[m],xs[m]], rcond=None)
    return coef

# ---------- bidon template from card 1 (clean) ----------
tx0,ty0,tx1,ty1 = 18,284,156,490
coef1 = fit_card(*cards[0])
ys,xs = np.mgrid[ty0:ty1, tx0:tx1]
bg = feats(xs.astype(float),ys.astype(float))@coef1
T = A[ty0:ty1, tx0:tx1]
dist = np.linalg.norm(T-bg,axis=-1)
alpha = np.clip((dist-18)/70.0,0,1)
# fg colour un-mixed
a3 = np.maximum(alpha,1e-3)[...,None]
fg = np.clip((T-(1-a3)*bg)/a3,0,255)
r,g,b = fg[...,0],fg[...,1],fg[...,2]
cap = (b-r>70)&(alpha>0.2)
L = fg.mean(-1)
BLUE = np.array([30,58,138],np.float32)      # bleu roi G-Clean
LIGHT = np.array([92,132,214],np.float32)
f = L/232.0
plast = np.where((f<=1)[...,None], BLUE*f[...,None],
                 BLUE+(LIGHT-BLUE)*np.clip((f-1)/0.09,0,1)[...,None])
# cap -> white, shaded by original brightness of blue channel
v = np.clip(b/225.0,0.55,1.08)
capc = np.clip(np.stack([246*v,248*v,252*v],-1),0,255)
newfg = np.where(cap[...,None], capc, plast)
# soften cap/plastic transition
tpl = newfg

FRAMES = {25:(20,104),222:(21,103),398:(19,105),651:(16,102),839:(19,105),1015:(17,105)}
def label_box(bl,bb):
    db=bb-480
    l,r = FRAMES[bl]
    return (bl+l, 334+db, bl+r, 455+db)

out_bidons=[]
for (x0,x1,bl,bb) in cards:
    img = tpl.copy()
    lx0,ly0,lx1,ly1 = label_box(bl,bb)
    lab = A[ly0:ly1, lx0:lx1]
    lab = np.asarray(Image.fromarray(np.clip(lab,0,255).astype(np.uint8)).resize((84,lab.shape[0]),Image.LANCZOS)).astype(np.float32)
    # place in template coords (template label at same rel position as card1)
    ox = (25+20)-tx0; oy = 334-ty0
    img[oy:oy+lab.shape[0], ox:ox+lab.shape[1]] = lab
    al = alpha.copy(); al[oy:oy+lab.shape[0], ox:ox+lab.shape[1]] = 1.0
    rgba = np.dstack([np.clip(img,0,255), al*255]).astype(np.uint8)
    im_ = Image.fromarray(rgba,'RGBA')
    out_bidons.append(im_.crop(im_.getchannel('A').point(lambda v:255 if v>20 else 0).getbbox()))

# ---------- build new page ----------
NH = H - D
N = np.zeros((NH,Wd,3),np.float32)
N[:110] = A[:110]
N[NEW_BAND:] = A[BAND:]
N[CARD_TOP:NEW_BAND] = A[BAND-NEW_H_ZONE:BAND]      # rows 312..580: no strokes in gaps
for (x0,x1,_,_) in cards:   # page background behind cards: bridge from neighbouring gaps
    L_ = N[CARD_TOP:NEW_BAND, x0-2]; R_ = N[CARD_TOP:NEW_BAND, x1+2]
    for x in range(x0-1,x1+2):
        t=(x-(x0-2))/((x1+2)-(x0-2))
        N[CARD_TOP:NEW_BAND, x] = L_*(1-t)+R_*t
for y in range(110,CARD_TOP):
    t=(y-109)/(CARD_TOP-109)
    N[y] = A[109]*(1-t) + N[CARD_TOP]*t
img = Image.fromarray(np.clip(N,0,255).astype(np.uint8))
# cards
S=4
for (x0,x1,bl,bb),bid in zip(cards,out_bidons):
    coef = fit_card(x0,x1,bl,bb)
    ys,xs = np.mgrid[CARD_TOP:NEW_BAND, x0:x1]
    yo = CARD_TOP + (ys-CARD_TOP)*((BAND-CARD_TOP)/NEW_H_ZONE)
    col = feats(xs.astype(float),yo.astype(float))@coef
    tile = Image.fromarray(np.clip(col,0,255).astype(np.uint8))
    w,h = x1-x0, NEW_BAND-CARD_TOP
    mk = Image.new('L',(w*S,(h+20)*S),0)
    ImageDraw.Draw(mk).rounded_rectangle([0,0,w*S-1,(h+20)*S-1],radius=9*S,fill=255)
    mk = mk.resize((w,h+20),Image.LANCZOS).crop((0,0,w,h))
    img.paste(tile,(x0,CARD_TOP),mk)
    # bidon, scaled
    sc = (w-16)/bid.width*1.0
    bw,bh = int(bid.width*sc), int(bid.height*sc)
    big = bid.resize((bw,bh),Image.LANCZOS)
    px_ = x0+(w-bw)//2
    py_ = CARD_TOP+(h-bh)//2
    # soft shadow
    sh = Image.new('L',(w,h),0)
    ImageDraw.Draw(sh).ellipse([ (w-bw)//2+8, py_-CARD_TOP+bh-14, (w+bw)//2-8, py_-CARD_TOP+bh+2],fill=110)
    sh = sh.filter(ImageFilter.GaussianBlur(5))
    shade = Image.new('RGB',(w,h),(5,15,40))
    img.paste(shade,(x0,CARD_TOP),Image.fromarray((np.asarray(sh)*np.asarray(mk)/255).astype(np.uint8)))
    img.paste(big,(px_,py_),big)

img.save(W+'/new_lowres.png')
big = img.resize((img.width*3,670*3),Image.LANCZOS).filter(ImageFilter.UnsharpMask(radius=2,percent=60,threshold=2))
big.crop((0,0,589*3,670*3)).save(W+'/GClean_page1_HD.png')
big.crop((590*3,0,1207*3,670*3)).save(W+'/GClean_page2_HD.png')
big.crop((0,0,1207*3,670*3)).save(W+'/GClean_2pages_HD.png')
print('new size',img.size,'scale',sc, 'removed',D)
