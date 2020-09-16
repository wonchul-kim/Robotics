import sys
sys.path.remove('/opt/ros/kinetic/lib/python2.7/dist-packages')

import cv2
import pyrealsense2 as pyrs
import numpy as np
import matplotlib.pyplot as plt


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

try:
    while True:
        frames = pipeline.wait_for_frames()
        depth_frame = frames.get_depth_frame()
        color_frame = frames.get_color_frame()

        # if not depth_frame or not color_frame:
        #     continue

        depth_image = np.asanyarray(depth_frame.get_data())
        color_image = np.asanyarray(color_frame.get_data())

        depth_colormap = cv2.applyColorMap(cv2.convertScaleAbs(depth_image, alpha=0.03), cv2.COLORMAP_JET)

        images = np.hstack((color_image, depth_colormap))

        hsv = cv2.cvtColor(color_image, cv2.COLOR_BGR2HSV)
        mask = cv2.inRange(hsv, lower_range, upper_range)

        # cv2.namedWindow('Realsense', cv2.WINDOW_AUTOSIZE)
        cv2.imshow('Realsense', images)
        cv2.imshow('mask', mask)
        cv2.waitKey(1)
        # while(1):
        #     k = cv2.waitKey(0)
        #     if(k == 27):
        #         break

    # cv2.destroyAllWindows()
finally:
    pipeline.stop()
