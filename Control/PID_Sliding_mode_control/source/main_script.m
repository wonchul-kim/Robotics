
clear all
clearvars -global

global dt
global g l
g = 9.81;
l = 0.4;
dt = 0.05;
T = 100;

t = 0:dt:T;

x_d = 5*cos(t);
y_d = 5*ones(size(t));
z_d = 5*ones(size(t));
phi_d = 0*ones(size(t));
theta_d = 0*ones(size(t));
psi_d = 0*ones(size(t));

for i = 1:length(t)
	X_d = [x_d(i), y_d(i), z_d(i), phi_d(i), theta_d(i), psi_d(i)].';
	
	controller_sliding([derivative(X_d); X_d; integrator(X_d)]);
	
end

quit