'''
file: donkey_sim.py
author: Tawn Kramer
date: 2018-08-31
'''
import json
import shutil
import base64
import random
import time
import os
import glob
from io import BytesIO
import subprocess

import numpy as np
import socketio
import eventlet
import eventlet.wsgi
from PIL import Image
from flask import Flask

sio = socketio.Server()

# This is to monkey_patch python standard library "magically". Without it server cannot actively push messages to Unity client through emit()
# Reference: https://github.com/miguelgrinberg/Flask-SocketIO/issues/357
eventlet.monkey_patch()

class DonkeyUnitySim(object):

    # Cross track error max
    CTE_MAX_ERR = 5.0

    def __init__(self, level, time_step=0.05):
        self.level = level
        self.time_step = time_step

        self.proc1 = None  # The process that is started. If None, no process was started

        # sensor size - height, width, depth
        self.camera_img_size=(120, 160, 3)
        
        self.app = Flask("DonkeyUnitySim")

        self.reset(intial=True)

    ## ------- Env interface ---------- ##

    def reset(self, intial=False):
        self.image_array = np.zeros(self.camera_img_size)
        self.hit = "none"
        self.cte = 0.0
        self.prev_cte = 0.0
        self.prev = 0.0
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
        self.loaded = False
        self.wait_for_obs = True
        self.have_new_obs = False
        if not intial:
            #this exit scene command will cause us to re-load the scene.
            #on scene load we will have a fresh observation to return from observe
            self.send_exit_scene()

    def get_sensor_size(self):
        return self.camera_img_size

    def take_action(self, action):
        self.wait_for_obs = True
        self.have_new_obs = False
        self.send_control(action[0], action[1])        

    def observe(self):
        assert(self.wait_for_obs)
        while not self.have_new_obs:
            time.sleep(0.0001)

        observation = self.image_array
        done = self.is_game_over()
        reward = self.calc_reward(done)
        info = {}

        self.wait_for_obs = False
        self.have_new_obs = False

        return observation, reward, done, info

    def quit(self):
        """
        Shutdown unity environment
        """
        if self.proc1 is not None:
            self.proc1.kill()

    def render(self, mode):
        pass

    def is_game_over(self):
        """
        Define end of episode
        """
        # Use car collision as done signal. 
        # A better termination might be when the car deviates from the track
        #return self.hit != "none"

        if abs(self.cte) > self.CTE_MAX_ERR or self.hit != "none":
            return -1.0

    ## ------ RL interface ----------- ##

    def calc_reward(self, done):
        if done:
            return -1.0

        if abs(self.cte) > self.CTE_MAX_ERR:
            return -1.0

        return 1.0 - (abs(self.cte) / self.CTE_MAX_ERR)


    ## ------ Launch Unity Env ----------- ##

    def executable_launcher(self, file_name, headless=False, platform="linux"):

        # TODO: Only for MACOS for now. Need to handle Linux
        cwd = os.getcwd()
        file_name = (file_name.strip().replace('.app', '').replace('.exe', '').replace('.x86_64', '').replace('.x86', ''))
        true_filename = os.path.basename(os.path.normpath(file_name))
        launch_string = None
        print('The true file name is {}'.format(true_filename))

        if platform == "linux":
            candidates = glob.glob(os.path.join(cwd, file_name) + '.x86_64')
            print(candidates)
            if len(candidates) == 0:
                candidates = glob.glob(os.path.join(cwd, file_name) + '.x86')
            if len(candidates) == 0:
                candidates = glob.glob(file_name + '.x86_64')
            if len(candidates) == 0:
                candidates = glob.glob(file_name + '.x86')
            if len(candidates) > 0:
                launch_string = candidates[0]

        elif platform == "darwin":
            candidates = glob.glob(os.path.join(cwd, file_name + '.app', 'Contents', 'MacOS', true_filename))
            if len(candidates) == 0:
                candidates = glob.glob(os.path.join(file_name + '.app', 'Contents', 'MacOS', true_filename))
            if len(candidates) == 0:
                candidates = glob.glob(os.path.join(cwd, file_name + '.app', 'Contents', 'MacOS', '*'))
            if len(candidates) == 0:
                candidates = glob.glob(os.path.join(file_name + '.app', 'Contents', 'MacOS', '*'))
            if len(candidates) > 0:
                launch_string = candidates[0]

        if launch_string is None:
            print("launch string is Null")
        else:
            print("This is the launch string {}".format(launch_string))

            # Launch Unity environment
            if headless:
                self.proc1 = subprocess.Popen(
                    [launch_string,'-nographics', '-batchmode'])
            else:
                self.proc1 = subprocess.Popen(
                    [launch_string])


    ## ------ Websocket interface ----------- ##

    def communicator(self, address = ('0.0.0.0', 9090)):
        """
        Communicate with Unity through Websocket. Set up Websocket Server and register events listeners
        """

        @sio.on('Telemetry')
        def telemetry(sid, data):
            if data:

                # The current image from the center camera of the car
                imgString = data["image"]
                image = Image.open(BytesIO(base64.b64decode(imgString)))
                self.image_array = np.asarray(image)

                # Name of object we just hit. "none" if nothing.
                self.hit = data["hit"]

                self.x = data["pos_x"]
                self.y = data["pos_y"]
                self.z = data["pos_z"]

                # Cross track error not always present.
                # Will be missing if path is not setup in the given scene.
                # It should be setup in the 3 scenes available now.
                try:
                    self.cte = data["cte"]
                except:
                    pass

                self.have_new_obs = True

            else:
                sio.emit('RequestTelemetry', data={}, skip_sid=True)

        @sio.on('connect')
        def connect(sid, environ):
            print("connect ", sid)
            step_mode = "synchronous"

            self.send_settings({"step_mode" : step_mode.__str__(),\
                "time_step" : self.time_step.__str__()})

        @sio.on('ProtocolVersion')
        def on_proto_version(sid, environ):
            print("ProtocolVersion ", sid)

        @sio.on('SceneSelectionReady')
        def on_fe_loaded(sid, environ):
            self.send_get_scene_names()

        @sio.on('SceneLoaded')
        def on_scene_loaded(sid, data):
            self.take_action((0, 0))

        @sio.on('SceneNames')
        def on_scene_names(sid, data):
            names = data['scene_names']
            self.send_load_scene(names[self.level])

        # wrap Flask application with engineio's middleware
        self.app = socketio.Middleware(sio, self.app)

        # deploy as an eventlet WSGI server
        try:
            eventlet.wsgi.server(eventlet.listen(address), self.app)
        except KeyboardInterrupt:
            #unless some hits Ctrl+C and then we get this interrupt
            print('stopping')


    ## ------- Unity Event Messages --------------- ##

    def send_get_scene_names(self):
        sio.emit(
            "GetSceneNames",
            data={            
            },
            skip_sid=True)

    def send_control(self, steering_angle, throttle):
        sio.emit(
            "Steer",
            data={
                'steering_angle': steering_angle.__str__(),
                'throttle': throttle.__str__()
            },
            skip_sid=True)

    def send_load_scene(self, scene_name):
        print("Loading", scene_name)
        sio.emit(
            "LoadScene",
            data={
                'scene_name': scene_name.__str__()
            },
            skip_sid=True)

    def send_exit_scene(self):
        sio.emit(
            "ExitScene",
            data={
                'none': 'none'
            },
            skip_sid=True)

    def send_reset_car(self):
        sio.emit(
            "ResetCar",
            data={            
            },
            skip_sid=True)

    def send_settings(self, prefs):
        sio.emit(
            "Settings",
            data=prefs,
            skip_sid=True)




