function [U, x_ref] = controller_sliding(X_dot_ref, X_ref, X_sum_ref, Z, X_obs)

global g l
global dt

persistent V
if isempty(V)
	V = [0 0 0 0 0 0]';
end

noise = 0;

%% Parse Inputs
x_dot_ref		= X_dot_ref(1);
y_dot_ref		= X_dot_ref(2);
z_dot_ref		= X_dot_ref(3);
psi_dot_ref		= X_dot_ref(4);

x_ref			= X_ref(1);
y_ref			= X_ref(2);
z_ref			= X_ref(3);
psi_ref			= X_ref(4);

x_ddot_ref		= derivative(x_dot_ref);
y_ddot_ref		= derivative(y_dot_ref);
z_ddot_ref		= derivative(z_dot_ref);
psi_ddot_ref	= derivative(psi_dot_ref);

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

%% Plant Parameter
F = [0 0 -g 0 0 0]';
G = [
	cos(phi)*sin(theta)*cos(psi)+sin(phi)*sin(psi) 0 0 0;
	cos(phi)*sin(theta)*sin(psi)-sin(phi)*cos(psi) 0 0 0;
	cos(phi)*cos(theta)							   0 0 0;
	0											   l 0 0;
	0											   0 l 0;
	0											   0 0 1;
	];
Gs = [
	1 0 0 0 0 0;
	0 1 0 0 0 0;].';
Gaug = [G Gs];
Gaug_inv = [
	0   0   1   0   0   0;
	0   0   0   1/l 0   0;
	0   0   0   0   1/l 0;
	0   0   0   0   0   1;
	1   0   0   0   0   0;
	0   1   0   0   0   0;
	];

%% Controller Parameter
% Sliding Mode Control Parameter
K = diag([.5 .5 .5 .5 .5 .1])*10;
C = diag([.2 .2 .2 2 2 .5])*57;
% K = diag([1 1 .7 5 5 10]);
% C = [5 5 5 1 1 1].'*10;
% K = diag([1 1 .7 285 285 570]);
% C = [5 5 5 57 57 57].';

% State
X			= [x y z phi theta psi]';
X_dot		= [x_dot y_dot z_dot phi_dot theta_dot psi_dot]';

X_ref		= [x_ref y_ref z_ref 0 0 psi_ref]';
X_dot_ref	= [x_dot_ref y_dot_ref z_dot_ref 0 0 psi_dot_ref]';

% Error State
E			= X - X_ref;
E_dot		= X_dot - X_dot_ref;

% Re-define State
phi_ref		= 0.2*E_dot(2) + 0.1*E(2);
theta_ref	= 0.2*E_dot(1) + 0.1*E(1);

convert		= [cos(psi) -sin(psi);sin(psi) cos(psi)]*[-theta_ref;phi_ref];
theta_ref	= convert(1);
phi_ref		= convert(2);

if abs(theta_ref) + abs(phi_ref) > 0.6
    theta_ref	= theta_ref / (abs(theta_ref)+abs(phi_ref)) * 0.6;
    phi_ref		= phi_ref   / (abs(theta_ref)+abs(phi_ref)) * 0.6;
end

X_ref		= [x_ref y_ref z_ref phi_ref theta_ref psi_ref]';
X_dot_ref	= [x_dot_ref y_dot_ref z_dot_ref 0 0 psi_dot_ref]';
X_ddot_ref	= [x_ddot_ref y_ddot_ref z_ddot_ref 0 0 psi_ddot_ref]';

% Re-define Error State
E			= X - X_ref;
E_dot		= X_dot - X_dot_ref;

%% Controller
% Sliding Mode Control; S := E' + K*E, S*S' < -C*|S|
S = E_dot + K*E;

% slack variable
V_dot = -[E_dot(1)+K(1,1)*E(1), E_dot(2)+K(2,2)*E(2), 0, 0, 0, 0].';
V = V + V_dot*dt;

% input
sat = saturation([-1, 1]);
U = Gaug_inv*( -F + V + X_ddot_ref - K*E_dot - C.'*evaluate(sat, .1*S));
% U = (Gaug)\( -F + V + X_ddot_ref - K*E_dot - C.'*S);

U = U(1:4)';

dx = [x;y;z] - X_obs;
repulsive = 50*(dx)/(norm(dx)^3).*(derivative(dx) < 0);

if any(repulsive > 1)
	U(1) = U(1) + repulsive(3);
	U(2) = U(2) - repulsive(2);
	U(3) = U(3) - repulsive(1);
end

x_ref = X_ref;