function [t, X_ref] = Initialize()
%
%

global g l
global dt T
global Z_ini

g = 9.81;
l = 0.4;

dt = 0.05;
T = 50;

t = 0:dt:T;

x_ref = 10*ones(size(t));
y_ref = 10*ones(size(t));
z_ref = 5*ones(size(t));
psi_ref = ones(size(t));

% x_ref = 10*cos(0.1*t);
% y_ref = 10*sin(0.1*t);
% z_ref = 5*ones(size(t));
% psi_ref = (0.1*t + pi).*ones(size(t));

Z_ini = [0 0 0 0 0 0  0 0 0 0 0 0]';

X_ref = [x_ref.', y_ref.', z_ref.', psi_ref.'].';