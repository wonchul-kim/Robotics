function obj = controller_sliding(obj, X_obs)

global g diameter
global dt

persistent V
if isempty(V)
	V = [0 0 0 0 0 0]';
end

ISREPULSIVE = true;
noise = 0;
obj_name = inputname(1);

%% Parse Inputs
X_ref = obj.ref;
X_dot_ref = derivative(X_ref, [obj_name '_X_ref']);
X_ddot_ref = derivative(X_dot_ref, [obj_name '_X_dot_ref']);
Z = obj.Z;

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
	0											   diameter 0 0;
	0											   0 diameter 0;
	0											   0 0 1;
	];
Gs = [
	1 0 0 0 0 0;
	0 1 0 0 0 0;].';
Gaug = [G Gs];
Gaug_inv = [
	0   0   1   0   0   0;
	0   0   0   1/diameter 0   0;
	0   0   0   0   1/diameter 0;
	0   0   0   0   0   1;
	1   0   0   0   0   0;
	0   1   0   0   0   0;
	];

%% Controller Parameter
% Sliding Mode Control Parameter
K = diag([.5 .5 .5 .5 .5 .1])*10;
C = diag([.2 .2 .2 2 2 .5])*57.3;
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

if ISREPULSIVE
	
% 	dx = repmat([x;y;z], 1, size(X_obs,2)) - X_obs;
% 	sat = saturation([0, inf]);
% 	dv = derivative(norm(dx), [obj_name '_dx']);
% 	v = derivative(norm([x;y;z]), [obj_name '_v']);
% 	
% 	if norm(dx) > 20*diameter
% 		repulsive = zeros(3, 1);
% 	else
% 		repulsive = 10 * (1/norm(dx) - 1/(20*diameter)) * sign(dx) ./ log(2 + abs(dx)) * evaluate(sat, -dv);
% % 		repulsive = 10 * expm(-norm(dx))/norm(dx).^2 * dx;
% 	% 	repulsive = 1 * (1/norm(dx) - 1/(8*l)) * dx / (norm(dx).^2) * evaluate(sat, -dv);
% 	end
	
	
	dx = repmat([x;y;z], 1, size(X_obs,2)) - X_obs;
	threshold = 0;
	sat = [0, 10];
	dv = derivative(norm(dx), [obj_name '_dx']);
	v = derivative(norm([x;y;z]), [obj_name '_v']);
	
	% a vector which is right to the directional vector
	yz = zeros(3, size(dx, 2));
	for i = 1:size(dx, 2)
		yz(:,i) = cross(dx(:,i), [0 0 -1] );
		if norm(yz(:,i)) / norm(dx(:,i)) < sin(pi/6);
			yz(:,i) = cross(dx(:,i), [1 0 0]);% + dx(:,i).';
		end
		yz(:,i) = yz(:,i)/norm(yz(:,i));
	end
	
	unit_dx = zeros(size(dx));
	for i = 1:size(dx, 2)
		unit_dx(:,i) = dx(:,i)/norm(dx(:,i));
	end
	
	repulsive = 5 * unit_dx * diag(max(min(-dv - threshold, sat(2)), sat(1))) ./ log(exp(1) + abs(dx));
% 	repulsive = 5 * (unit_dx + yz) * diag(max(min(-dv - threshold, sat(2)), sat(1))) ./ log(exp(1) + abs(dx));
	repulsive = sum(repulsive, 2) * log(exp(1) + abs(v));

else
	
	repulsive = zeros(3, 1);
end

if any(abs(repulsive) > .1)
	U(1) = U(1) - 0.5*repulsive(3);
	U(2) = U(2) - repulsive(2);
	U(3) = U(3) + repulsive(1);
end

obj.ref = X_ref;
obj.input = U;
obj.repulsive = repulsive;

% disp(U);
% disp(repulsive);