function t = Initialize()
%
%

global g diameter
global dt T
global N

g = 9.81;
diameter = 0.4;

dt = 0.05;
T = 10;

t = 0:dt:T;

N = 4;