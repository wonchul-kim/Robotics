function [ t, X_ref ] = initialize()

global g l
global dt T
global feedback_init

g = 9.81;
l = 0.4;

dt = 0.05;
T = 70;

t = 0:dt:T;

x_ref = 10*cos(0.1*t);
y_ref = 10*sin(0.1*t);
z_ref = 5*ones(size(t));
psi_ref = (0.1*t + pi).*ones(size(t));

X_ref = [x_ref.', y_ref.', z_ref.', psi_ref.'].';

feedback_init = [0 0 0 0 0 0      0 0 0 0 0 0]';

end

