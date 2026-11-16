import cv2, numpy as np
img = cv2.imread('assets/jar_x4.png')
g = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
fg = (g > 40).astype(np.uint8)
n, lab, st, _ = cv2.connectedComponentsWithStats(fg, 8)
big = 1 + np.argmax(st[1:, cv2.CC_STAT_AREA]); m = (lab == big).astype(np.uint8)*255
# fill holes
inv = 255 - m; ff = inv.copy(); h,w = m.shape
cv2.floodFill(ff, np.zeros((h+2,w+2),np.uint8), (0,0), 0); m = m | ff
m = cv2.morphologyEx(m, cv2.MORPH_OPEN, np.ones((9,9),np.uint8))
m = cv2.erode(m, np.ones((5,5),np.uint8))
m = cv2.GaussianBlur(m, (0,0), 2.5)
x,y,bw,bh = cv2.boundingRect((m>10).astype(np.uint8))
rgba = np.dstack([img, m])[y:y+bh, x:x+bw]
cv2.imwrite('assets/jar.png', rgba); print(rgba.shape)
# preview on red
a = rgba[...,3:4]/255.; prev = (rgba[...,:3]*a + np.array([40,40,200])*(1-a)).astype(np.uint8)
cv2.imwrite('prev_jar.jpg', cv2.resize(prev, None, fx=0.2, fy=0.2))
