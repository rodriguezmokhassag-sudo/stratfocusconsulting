# Afro-pop / amapiano-style 20 s bed, fully synthesized (no third-party samples -> royalty free)
import numpy as np, wave
from scipy.signal import butter, sosfilt
SR=48000; DUR=20.0; BPM=108; B=60/BPM; N=int(SR*DUR)
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
# progression (A minor-ish afro pop): F  G  Am  C  - one chord per bar
prog=[[53,57,60,64],[55,59,62,65],[57,60,64,67],[52,55,60,64]]
roots=[41,43,45,48]
bars=int(DUR/(4*B))+1
for bar in range(bars):
    t0=bar*4*B; ch=prog[bar%4]; rt=roots[bar%4]
    intro = t0<2*B*0.99  # first half-bar sparse
    for s in range(16):
        t=t0+s*B/4
        if t>=DUR: break
        a=[1,.4,.7,.4][s%4]
        add(shaker(a*.12),t,1,.3)
        if t<.9*B*2: continue
        if s in (0,8) or (s==10 and bar%2): add(kick(),t,.85)
        if s in (4,12): add(clap(),t,.32,-.1)
        if s in (3,6,11,14): add(conga(64+(s%3)),t,.13,-.4)
        if s in (2,6,10,14): add(keys(ch),t,.22,.15)
    if t0>=B*2*.9:
        for s,mm in [(0,0),(3,0),(6,12),(10,7),(12,0),(14,10)]:
            add(logdrum(rt-12+mm),t0+s*B/4,.38)
    mel=[[72,69,67],[71,67,74],[72,76,74],[72,67,69]][bar%4]
    if 2<=bar<=6:
        for k,mm in enumerate(mel): add(marimba(mm),t0+(1.5+k)*B,.12,-.25)
CUT=4*B*1.5
for k in range(1,4): add(whoosh(.45),k*CUT-.3,.18)
add(whoosh(.9),6*B*4/4*0+4*CUT-.85,.25)
add(impact(),4*CUT,.45)
OUT0=4*CUT
for d in (.3,.5,.62,.74,1.5,1.62,1.74,1.84): add(pop(),OUT0+d,.10,0)
mix=np.stack([L,R],1)
fade=np.ones(N); fn=int(2.0*SR); fade[-fn:]=np.linspace(1,0,fn)**1.5; fade[:int(.05*SR)]=np.linspace(0,1,int(.05*SR))
mix*=fade[:,None]; mix=np.tanh(mix*1.1); mix/=np.abs(mix).max()/0.89
with wave.open('music.wav','wb') as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR); w.writeframes((mix*32767).astype('<i2').tobytes())
print('ok', CUT, OUT0)
