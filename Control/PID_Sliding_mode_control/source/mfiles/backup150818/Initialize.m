function t = Initialize()
%
%

global g l
global dt T
global N

g = 9.81;
l = 0.4;

dt = 0.05;
T = 30;

t = 0:dt:T;