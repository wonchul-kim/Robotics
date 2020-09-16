function obj = controller_pd(obj, X_obs)

noise = 0.0;
obj_name = inputname(1);

%% Parse Inputs
X_ref = obj.ref;
X_dot_ref = derivative(X_ref, [obj_name '_X_ref']);
X_ddot_ref = derivative(X_dot_ref, [obj_name '_X_dot_ref']);
X_sum_ref = integrator(X_ref, [obj_name '_X_sum_ref'], X_ref);

Z = obj.Z;
Z_sum = integrator(Z, [obj_name '_Z_sum'], obj.Z);

x_ref			= X_ref(1);
y_ref			= X_ref(2);
z_ref			= X_ref(3);
psi_ref			= X_ref(4);

x_dot_ref		= X_dot_ref(1);
y_dot_ref		= X_dot_ref(2);
z_dot_ref		= X_dot_ref(3);
psi_dot_ref		= X_dot_ref(4);

x_ddot_ref		= X_ddot_ref(1);
y_ddot_ref		= X_ddot_ref(2);
z_ddot_ref		= X_ddot_ref(3);
psi_ddot_ref	= X_ddot_ref(4);

x_sum_ref			= X_sum_ref(1);
y_sum_ref			= X_sum_ref(2);
z_sum_ref			= X_sum_ref(3);
psi_sum_ref			= X_sum_ref(4);

x				= Z(1) + noise*randn();
y				= Z(2) + noise*randn();
z				= Z(3) + noise*randn();
phi				= Z(4) + .5*noise*randn();
theta			= Z(5) + .5*noise*randn();
psi				= Z(6) + .5*noise*randn();

x_dot			= Z(7) + noise*randn();
y_dot			= Z(8) + noise*randn();
z_dot			= Z(9) + noise*randn();
phi_dot			= Z(10) + .5*noise*randn();
theta_dot		= Z(11) + .5*noise*randn();
psi_dot			= Z(12) + .5*noise*randn();

x_sum			= Z_sum(1) + noise*randn();
y_sum			= Z_sum(2) + noise*randn();
z_sum			= Z_sum(3) + noise*randn();
phi_sum			= Z_sum(4) + .5*noise*randn();
theta_sum		= Z_sum(5) + .5*noise*randn();
psi_sum			= Z_sum(6) + .5*noise*randn();

%%
a = 2e-1;
b = 1e-1;
c = 1e-2;
phi_ref = a*(y_dot_ref-y_dot)+b*(y_ref-y)+c*(y_sum_ref - y_sum);
theta_ref = a*(x_dot_ref-x_dot)+b*(x_ref-x)+c*(x_sum_ref - x_sum);

convert = [cos(psi) -sin(psi);sin(psi) cos(psi)]*[theta_ref;-phi_ref];
theta_ref = convert(1);
phi_ref = convert(2);

if abs(theta_ref)+abs(phi_ref) > 0.6
    theta_ref = theta_ref / (abs(theta_ref)+abs(phi_ref)) * 0.6;
    phi_ref = phi_ref / (abs(theta_ref)+abs(phi_ref)) * 0.6;
end


% Gain
kp_phi = 50;    kd_phi = 20;
kp_theta = 50;  kd_theta = 15;
kp_psi = 5;     kd_psi = 5;      ki_psi = 1;
kp_z = 8;       kd_z = 10;       ki_z = .2; 

% input
u1 = kp_z*(z_ref-z)				+	kd_z*(z_dot_ref-z_dot)		 + ki_z*(z_sum_ref - z_sum) + 9.81;
u2 = kp_phi*(phi_ref-phi)		+	kd_phi*(0-phi_dot);
u3 = kp_theta*(theta_ref-theta)	+	kd_theta*(0-theta_dot);
u4 = kp_psi*(psi_ref-psi)		+	kd_psi*(psi_dot_ref-psi_dot) + ki_psi*(psi_sum_ref-psi_sum);

% repulsive = ([x;y;z] - X_obs)/(norm([x;y;z] - X_obs)^3);
% 
% if any(repulsive > 1)
% 	u1 = u1 + repulsive(3);
% 	u2 = u2 - repulsive(2);
% 	u3 = u3 - repulsive(1);
% end

U = [u1;u2;u3;u4];
X_ref = [x_ref y_ref z_ref phi_ref theta_ref psi_ref]';

obj.ref = X_ref;
obj.input = U;
obj.repulsive = zeros(3,1);