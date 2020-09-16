import sys
sys.path.remove('/opt/ros/kinetic/lib/python2.7/dist-packages')

import cv2
import pyrealsense2 as pyrs
import numpy as np
import matplotlib.pyplot as plt
import imutils
from collections import deque

pipeline = pyrs.pipeline()
config = pyrs.config()
config.enable_stream(pyrs.stream.depth, 640, 480, pyrs.format.z16, 30)
config.enable_stream(pyrs.stream.color, 640, 480, pyrs.format.bgr8, 30)
pipeline.start(config)

# blue = sys.argv[1]
# green = sys.argv[2]
# red = sys.argv[3]

# color = np.unit8([[[blue, green, red]]])
lower_range = np.array([0, 150, 150], dtype=np.uint8)
upper_range = np.array([64, 255, 255], dtype=np.uint8)

pts = deque(maxlen=100)

try:
    while True:
        frames = pipeline.wait_for_frames()
        depth_frame = frames.get_depth_frame()
        color_frame = frames.get_color_frame()

        if not depth_frame or not color_frame:
            continue

        depth_image = np.asanyarray(depth_frame.get_data())
        color_image = np.asanyarray(color_frame.get_data())

        depth_colormap = cv2.applyColorMap(cv2.convertScaleAbs(depth_image, alpha=0.03), cv2.COLORMAP_JET)

        images = np.hstack((color_image, depth_colormap))
        

        frame = imutils.resize(color_image, width=600)
        # frame = imutils.rotate(color_image, angle=180)
        
        hsv = cv2.cvtColor(color_image, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, lower_range, upper_range)
        mask = cv2.erode(mask, None, iterations=2)
        mask = cv2.dilate(mask, None, iterations=2)

        _, cnts, _ = cv2.findContours(mask.copy(), cv2.RETR_EXTERNAL, 
                                cv2.CHAIN_APPROX_SIMPLE)
        center = None

        if len(cnts) > 0:
            c = max(cnts, key=cv2.contourArea)
            ((x, y), radius) = cv2.minEnclosingCircle(c)
            M = cv2.moments(c)
            # print(M)
            cx = int(M['m10']/M['m00'])
            cy = int(M['m01']/M['m00'])
            center = (cx, cy)

            if radius > 10:
                # draw the circle and centroid on the frame,
                # then update the list of tracked points
                cv2.circle(frame, (int(x), int(y)), int(radius),
                    (0, 255, 255), 2)
                cv2.circle(frame, center, 5, (0, 0, 255), -1)

        pts.appendleft(center)

        for i in range(1, len(pts)):
            # if either of the tracked points are None, ignore
            # them
            if pts[i - 1] is None or pts[i] is None:
                continue
    
            # otherwise, compute the thickness of the line and
            # draw the connecting lines
            thickness = int(np.sqrt(100 / float(i + 1)) * 2.5)
            cv2.line(frame, pts[i - 1], pts[i], (0, 0, 255), thickness)

            cv2.imshow('Frame', frame)
            key = cv2.waitKey(1) & 0xFF
            
            if key == ord("q"):
                    break

    cv2.destroyAllWindows()
finally:
    pipeline.stop()
