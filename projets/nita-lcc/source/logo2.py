import cv2, numpy as np
L=cv2.imread('../images/2.jpg'); crop=L[40:540, 450:946]
sr=cv2.dnn_superres.DnnSuperResImpl_create(); sr.readModel('models/EDSR_x4.pb'); sr.setModel('edsr',4)
up=sr.upsample(crop)
white=(up.min(2)>225).astype(np.uint8)
n,lab=cv2.connectedComponents(white,4)
bglabels=set(np.unique(np.concatenate([lab[0],lab[-1],lab[:,0],lab[:,-1]])))
bg=np.isin(lab,[l for l in bglabels if l!=0] ).astype(np.uint8) & white
fg=(1-bg).astype(np.uint8)*255
fg=cv2.morphologyEx(fg,cv2.MORPH_OPEN,np.ones((5,5),np.uint8))
a=cv2.GaussianBlur(fg,(0,0),1.6)
cv2.imwrite('assets/lcc_map.png',np.dstack([up,a]))
al=a[...,None]/255.; b=np.full(up.shape,(60,160,60),np.float32)
cv2.imwrite('prev_map.jpg', cv2.resize((up*al+b*(1-al)).astype(np.uint8),None,fx=0.25,fy=0.25))
