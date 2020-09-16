function output = controller_sliding(input)

global g l

noise = 0;


%% Parse Inputs
x_dot_ref = input(1);
y_dot_ref = input(2);
z_dot_ref = input(3);
psi_dot_ref = input(4);

x_ref = input(5);
y_ref = input(6);
z_ref = input(7);
psi_ref = input(8);

x_sum_ref = input(9);
y_sum_ref = input(10);
z_sum_ref = input(11);
psi_sum_ref = input(12);

x = input(13) + .5*noise*randn();
y = input(14) + .5*noise*randn();
z = input(15) + .5*noise*randn();
phi = input(16) + noise*randn();
theta = input(17) + noise*randn();
psi = input(18) + noise*randn();

x_dot = input(19) + noise*randn();
y_dot = input(20) + noise*randn();
z_dot = input(21) + noise*randn();
phi_dot = input(22) + .5*noise*randn();
theta_dot = input(23) + .5*noise*randn();
psi_dot = input(24) + .5*noise*randn();

V = [input(25) input(26) 0 0 0 0]';

x_ddot_ref = input(27);
y_ddot_ref = input(28);
z_ddot_ref = input(29);
psi_ddot_ref = input(30);


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

%% Controller Parameter
% Sliding Mode Control Parameter
K = diag([1 1 .7 285 285 570]);
C = diag([5 5 5 57 57 57]);

% State
X = [x y z phi theta psi]';
X_dot = [x_dot y_dot z_dot phi_dot theta_dot psi_dot]';

X_ref = [x_ref y_ref z_ref 0 0 psi_ref]';
X_dot_ref = [x_dot_ref y_dot_ref z_dot_ref 0 0 psi_dot_ref]';

% Error State
E = X - X_ref;
E_dot = X_dot - X_dot_ref;

% Re-define State
phi_ref = (20*E_dot(2)+K(4,4)*E(2));
theta_ref = (20*E_dot(1)+K(5,5)*E(1));

convert = [cos(psi) -sin(psi);sin(psi) cos(psi)]*[-theta_ref;phi_ref];
theta_ref = convert(1);
phi_ref = convert(2);

if abs(theta_ref)+abs(phi_ref) > 0.6
    theta_ref = theta_ref / (abs(theta_ref)+abs(phi_ref)) * 0.6;
    phi_ref = phi_ref / (abs(theta_ref)+abs(phi_ref)) * 0.6;
end

X_ref = [x_ref y_ref z_ref phi_ref theta_ref psi_ref]';
X_dot_ref = [x_dot_ref y_dot_ref z_dot_ref 0 0 psi_dot_ref]';
X_ddot_ref = [x_ddot_ref y_ddot_ref z_ddot_ref 0 0 psi_ddot_ref]';

% Re-define Error State
E = X - X_ref;
E_dot = X_dot - X_dot_ref;

%% Controller
% Sliding Mode Control; S := E' + K*E, S*S' < -C*|S|
S = E_dot + K*E;

% slack variable
V_dot = -[E_dot(1)+K(1,1)*E(1), E_dot(2)+K(2,2)*E(2), 0, 0, 0, 0].';

% input
sat = saturation([-1, 1]);
U = (Gaug)\( -F + V + X_ddot_ref - K*E_dot - C.'*evaluate(sat, .1*S));
% U = (Gaug)\( -F + V + X_ddot_ref - K*E_dot - C.'*sign(S));

u1 = U(1);
u2 = U(2);
u3 = U(3);
u4 = U(4);
u5 = U(5);
u6 = U(6);
v1 = V_dot(1)
v2 = V_dot(2)

output = [u1 u2 u3 u4 u5 u6 v1 v2]';
