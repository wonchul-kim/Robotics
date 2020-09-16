function [ t, X_ref ] = initialize()

global g l
global dt T
global feedback_init

g = 9.81;
l = 0.4;

dt = 0.05;
T = 50;

t = 0:dt:T;

% input - x, y, z, yaw - row vector (1 x ...)
% trajectory - circular path
x_ref = 10 * cos(0.1*t);
y_ref = 10 * sin(0.1*t);
z_ref = 5 * ones(size(t));
psi_ref = (0.1*t + pi) .* ones(size(t));

X_ref = [x_ref.', y_ref.', z_ref.', psi_ref.'].';   % 4 by (T/dt)

feedback_init = [0 0 0 0 0 0      0 0 0 0 0 0]';

end

