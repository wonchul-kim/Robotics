function [ t, X_ref ] = initialize()

global g l
global dt T
global feedback_init

g = 9.81;
l = 0.4;

dt = 0.05;
T = 50;

t = 0:dt:T;

% straight path
% x_ref = t;
% y_ref = 4*sin(t);
% z_ref = 5*ones(size(t));
% psi_ref = ones(size(t));

x_ref = 0.3*t;
y_ref = 5*sin(0.3*t);
z_ref = 5*ones(size(t));
psi_ref = (0.1*t + pi).*ones(size(t));

X_ref = [x_ref.', y_ref.', z_ref.', psi_ref.'].';

feedback_init = [0 0 0 0 0 0      0 0 0 0 0 0]';

end

