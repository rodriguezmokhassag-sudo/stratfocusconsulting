import cv2, numpy as np, time
sr = cv2.dnn_superres.DnnSuperResImpl_create()
sr.readModel('models/EDSR_x4.pb'); sr.setModel('edsr', 4)
img = cv2.imread('../images/1.jpg')
h, w = img.shape[:2]; T=180; P=12
out = np.zeros((h*4, w*4, 3), np.uint8); t=time.time()
for y in range(0, h, T):
    for x in range(0, w, T):
        y0, x0 = max(0,y-P), max(0,x-P); y1, x1 = min(h,y+T+P), min(w,x+T+P)
        up = sr.upsample(img[y0:y1, x0:x1])
        oy, ox = (y-y0)*4, (x-x0)*4; th, tw = min(T,h-y)*4, min(T,w-x)*4
        out[y*4:y*4+th, x*4:x*4+tw] = up[oy:oy+th, ox:ox+tw]
    print(y, time.time()-t, flush=True)
cv2.imwrite('assets/jar_x4.png', out)
