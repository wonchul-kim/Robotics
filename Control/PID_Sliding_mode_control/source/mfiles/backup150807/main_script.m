
clear all
clearvars -global

global Z_ini

[t, X_ref] = Initialize();

Z = Z_ini;
X_obs = [0, 10, 5]';

output = zeros(12, length(t)+1);
ref = zeros(6, length(t)+1);
output(:,1) = Z_ini;

for i = 1:length(t)
	
	X_ref_i = X_ref(:,i);
	
	[U, x_ref] = controller_sliding(derivative(X_ref_i), X_ref_i, integrator(X_ref_i), Z, X_obs);
	Z = dynamics(U);
	
	ref(:,i) = x_ref;
	output(:,i+1) = Z;
end

quad_plot();