# How to install roboschool

### Installation guide
* download the install file and assign the path variable
```
git clone https://github.com/openai/roboschool
ROBOSCHOOL_PATH=/path/to/roboschool
```
(If the path is not exact, this cannot be installed)

* install dependecies for Ubuntu
```
sudo apt install cmake ffmpeg pkg-config qtbase5-dev libqt5opengl5-dev libpython3.5-dev libboost-python-dev libtinyxml-dev
```
If you are using python3.6, 
```
sudo apt install libpython3.6-dev
```

> For now, when I write this article, there is no proper libboost-python-dev for python3.6.
  Thus, I just changed libboost-python-py35.so to libboost-python-py36.so as I am trying to use python3.6.
  To do this, follow the below:
```
cd /usr/lib/x86_64-linux-gnu
ln s libboost_python-py35.so libboost_python-py36.so 
```
(Note that I am not sure it is working properly...)

* Install bullet3 for physical engines under roboschool directory(ROBOSCHOOL_PATH)
```
git clone https://github.com/olegklimov/bullet3 -b roboschool_self_collision
mkdir bullet3/build
cd bullet3/build
cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 _DCMAKE_INSTALL_PREFIX:PATH=$ROBOSCHOOL_PATH/roboschool/cpp-household/bullet_local_install -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF ..
make -j4
make install
cd ../..
```
> Need to make sure that there appears folder named <U>bullet_local_install</U>
  If not, reassign the ROBOSCHOOL_PATH to path/to/roboschool and reinstall bullet3.
  After that, reinstall bullet3 with rearraned ROBOSCHOOL_PATH.
  
  
* Install roboschool (need 'gym')
```
pip install gym
pip install -e $ROBOSCHOOL_PATH
```
> Or, you can try this in the roboschool directory where setup.py is:
  ```
  python setup.py install 
  ```
  
