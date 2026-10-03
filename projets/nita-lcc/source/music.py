# Afro-pop / amapiano-style 20 s bed, fully synthesized (no third-party samples -> royalty free)
import numpy as np, wave
from scipy.signal import butter, sosfilt
SR=48000; DUR=20.0; BPM=120; B=60/BPM; N=int(SR*DUR)
L=np.zeros(N); R=np.zeros(N); rng=np.random.default_rng(7)
def add(sig,t,gain=1.0,pan=0.0):
    i=int(t*SR); n=min(len(sig),N-i)
    if n<=0: return
    L[i:i+n]+=sig[:n]*gain*(1-max(pan,0)); R[i:i+n]+=sig[:n]*gain*(1+min(pan,0))
def env(n,a,d): t=np.arange(n)/SR; return np.minimum(t/a,1)*np.exp(-t/d)
def hp(x,f): return sosfilt(butter(2,f,'hp',fs=SR,output='sos'),x)
def bp(x,f1,f2): return sosfilt(butter(2,[f1,f2],'bp',fs=SR,output='sos'),x)
def lp(x,f): return sosfilt(butter(2,f,'lp',fs=SR,output='sos'),x)
def m2f(m): return 440*2**((m-69)/12)
def kick():
    n=int(.45*SR); t=np.arange(n)/SR; f=45+90*np.exp(-t/.035)
    return np.tanh(1.6*np.sin(2*np.pi*np.cumsum(f)/SR)*np.exp(-t/.16))
def logdrum(m,d=.38):
    n=int(d*1.6*SR); t=np.arange(n)/SR; f=m2f(m)*(1+.6*np.exp(-t/.02))
    s=np.sin(2*np.pi*np.cumsum(f)/SR)+.3*np.sin(4*np.pi*np.cumsum(f)/SR)
    return np.tanh(2.2*s*env(n,.003,d))*.8
def shaker(acc):
    n=int(.09*SR); return hp(rng.standard_normal(n),6000)*env(n,.004,.025)*acc
def clap():
    n=int(.25*SR); x=bp(rng.standard_normal(n),900,5000); e=np.zeros(n)
    for k in (0,.011,.022): e+=env(n,.001,.012)*(np.arange(n)/SR>=k)
    return x*(e*.6+env(n,.002,.09)*.5)
def conga(m):
    n=int(.25*SR); t=np.arange(n)/SR; f=m2f(m)*(1+.25*np.exp(-t/.01))
    return np.sin(2*np.pi*np.cumsum(f)/SR)*env(n,.001,.07)
def keys(ms,d=.32):
    n=int(d*2.5*SR); t=np.arange(n)/SR; s=np.zeros(n)
    for m in ms:
        f=m2f(m); s+=(np.sin(2*np.pi*f*t)+.35*np.sin(4*np.pi*f*t+.3)+.12*np.sin(6*np.pi*f*t))*np.exp(-t/d)
    return lp(s*np.minimum(t/.004,1),4500)/len(ms)
def marimba(m):
    n=int(.6*SR); t=np.arange(n)/SR; f=m2f(m)
    return (np.sin(2*np.pi*f*t)+.25*np.sin(2*np.pi*4*f*t)*np.exp(-t/.02))*env(n,.002,.18)
def whoosh(d=.55,up=True):
    n=int(d*SR); x=rng.standard_normal(n); out=np.zeros(n); seg=n//24
    for k in range(24):
        fr=k/23 if up else 1-k/23; f=500+6000*fr**2
        out[k*seg:(k+1)*seg]=bp(x[k*seg:(k+1)*seg+0],f*.7,min(f*1.4,20000))
    w=np.sin(np.pi*np.arange(n)/n)**2; return out*w
def pop():
    n=int(.12*SR); t=np.arange(n)/SR; return np.sin(2*np.pi*np.cumsum(900*np.exp(-t/.03)+300)/SR)*env(n,.001,.03)
def impact():
    n=int(1.6*SR); t=np.arange(n)/SR
    return np.tanh(2*np.sin(2*np.pi*np.cumsum(30+70*np.exp(-t/.06))/SR)*np.exp(-t/.5))+lp(rng.standard_normal(n),1200)*np.exp(-t/.25)*.3

def hat(open_=False):
    n=int((.18 if open_ else .05)*SR); return hp(rng.standard_normal(n),8000)*env(n,.002,.06 if open_ else .015)
def snare():
    n=int(.22*SR); t=np.arange(n)/SR
    return bp(rng.standard_normal(n),1500,7000)*env(n,.001,.07)*.8+np.sin(2*np.pi*190*t)*env(n,.001,.05)
def stab(ms):
    n=int(.28*SR); t=np.arange(n)/SR; s=np.zeros(n)
    for m in ms:
        f=m2f(m)
        for det in (-.006,0,.006): s+=np.sign(np.sin(2*np.pi*f*(1+det)*t))*.33
    return lp(s,2800)*env(n,.004,.09)/len(ms)
def riser(d):
    n=int(d*SR); t=np.arange(n)/SR; x=rng.standard_normal(n); out=np.zeros(n); seg=n//32
    for k in range(32): f=400+9000*(k/31)**2; out[k*seg:(k+1)*seg]=bp(x[k*seg:(k+1)*seg],f*.6,min(f*1.5,20000))
    return out*(t/d)**2
prog=[[53,57,60,64],[55,59,62,65],[57,60,64,67],[52,55,60,64]]
roots=[41,43,45,40]
bars=int(DUR/(4*B))+1
# sidechain envelope (pumping on every beat)
sc=np.ones(N); pl=int(.18*SR)
for b in range(int(DUR/B)+1):
    i=int(b*B*SR); n=min(pl,N-i)
    if n>0: sc[i:i+n]=np.minimum(sc[i:i+n],.35+.65*np.linspace(0,1,n)**.7)
Lp=np.zeros(N); Rp=np.zeros(N)
def addp(sig,t,gain=1.0,pan=0.0):
    i=int(t*SR); n=min(len(sig),N-i)
    if n<=0: return
    Lp[i:i+n]+=sig[:n]*gain*(1-max(pan,0)); Rp[i:i+n]+=sig[:n]*gain*(1+min(pan,0))
CUTS=[3.0,6.0,9.0,12.0]
for bar in range(bars):
    t0=bar*4*B; ch=prog[bar%4]; rt=roots[bar%4]
    for s in range(16):
        t=t0+s*B/4
        if t>=DUR: break
        a=[1,.45,.75,.45][s%4]
        add(shaker(a*.14),t,1,.35)
        if s%4==0: add(kick(),t,.95)
        if s%4==2: add(hat(True),t,.16,-.2)
        if s%2==1: add(hat(),t,.07,.25)
        if s in (4,12): add(clap(),t,.36,-.05); add(snare(),t,.18,.05)
        if s in (3,6,10,13,15): add(conga(62+(s%4)*2),t,.16,-.45)
        if s in (2,7,9,14): add(conga(69),t,.10,.45)
        if s in (2,5,10,13): addp(keys(ch,.22),t,.24,.15)
        if s in (0,3,6,8,11,14): addp(stab([m+12 for m in ch[1:]]),t,.11,-.1)
    for s,mm in [(0,0),(3,0),(6,12),(8,7),(10,0),(11,12),(14,10)]:
        addp(logdrum(rt-12+mm,.28),t0+s*B/4,.42)
    mel=[[72,74,76,74,72],[71,74,72,71,67],[72,76,79,76,74],[72,71,67,69,72]][bar%4]
    if bar>=1:
        for k,mm in enumerate(mel): addp(marimba(mm),t0+(k*0.75+.5)*B,.13,-.25)
# snare roll + riser before each cut
for c in CUTS:
    for k in range(8): add(snare(),c-B+k*B/8,.06+.02*k,.0)
    add(riser(1.0 if c<12 else 2.0),c-(1.0 if c<12 else 2.0),.2 if c<12 else .3)
    add(whoosh(.45),c-.25,.15)
add(impact(),12.0,.5)
for d in (.3,.55,.7,.85,1.6,1.75,1.9,2.0,4.0,4.3): add(pop(),12.0+d,.10,0)
L+=Lp*sc; R+=Rp*sc
mix=np.stack([L,R],1)
fade=np.ones(N); fn=int(1.8*SR); fade[-fn:]=np.linspace(1,0,fn)**1.5; fade[:int(.02*SR)]=np.linspace(0,1,int(.02*SR))
mix*=fade[:,None]; mix=np.tanh(mix*1.3); mix/=np.abs(mix).max()/0.89
with wave.open('music.wav','wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes((mix*32767).astype('<i2').tobytes())
print('ok')
