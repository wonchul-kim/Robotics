function [U, X_ref, dd] = controller_sliding_control(X_dot_ref, X_ref, feedback, obstacle, obstacle2)

global g l
global dt

persistent V
if isempty(V)
	V = [0 0 0 0 0 0]';
end

noise = 0;

%% Parse Inputs
x_dot_ref               = X_dot_ref(1);
y_dot_ref               = X_dot_ref(2);
z_dot_ref       		= X_dot_ref(3);
psi_dot_ref             = X_dot_ref(4);

x_ref               	= X_ref(1);
y_ref                   = X_ref(2);
z_ref       			= X_ref(3);
psi_ref                 = X_ref(4);

x_ddot_ref              = derivative(x_dot_ref);
y_ddot_ref              = derivative(y_dot_ref);
z_ddot_ref      		= derivative(z_dot_ref);
psi_ddot_ref            = derivative(psi_dot_ref);

x                       = feedback(1); 
y                       = feedback(2); 
z           			= feedback(3);
phi                     = feedback(4);
theta                   = feedback(5);
psi                     = feedback(6);

x_dot                   = feedback(7);
y_dot                   = feedback(8);
z_dot               	= feedback(9);
phi_dot                 = feedback(10);
theta_dot               = feedback(11);
psi_dot                 = feedback(12);

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
sat = saturation([-2, 2]); % to remove sensor noise
U = Gaug_inv*( -F + V + X_ddot_ref - K*E_dot - C.'*evaluate(sat, 0.1*S));
% U = (Gaug)\( -F + V + X_ddot_ref - K*E_dot - C.'*S); % ???
% U = Gaug_inv*( -F + V + X_ddot_ref - K*E_dot - C.'*sign(S));
U = U(1:4)';
X_ref = X_ref;

%% avoidance obstacle --- 2D
% lineInterSectsCircle = 0;
% position = [x; y; z];
% velocity = [x_dot; y_dot; z_dot];
% % MAX_SEE_AHEAD = 200;
% ahead = @(x1, x2) x1 + norm(x2); 
% head_ = ahead(position, velocity);
% % distance = position - head_;
% distance = @(x1, x2) sqrt((x1(1, 1) - x2(1, 1))^2 + (x1(2, 1) - x2(2, 1))^2 + (x1(3, 1) - x2(3, 1))^2);
% repulsive = distance(obstacle, head_);
% % force = [x, y]' - obstacle(1:2, 1);
% % force = norm(force)*20;
% force = head_ - obstacle;
% avoid_force = norm(force)*8;
% % if any(force(1,1) < -0.5 && force(1,1) > -3)
% if any(repulsive < 4)
% 
% % %  	U(1) = U(1) - force/repulsive(3);
% 	U(2) = U(2) - avoid_force;
% 	U(3) = U(3) - avoid_force;
% end
% if (derivative(distance(obstacle(1:2, 1), position(1:2, 1))) < 0)
%     lineInterSectsCircle = 1;
% avoidance_force = [x, y]' - obstacle(1:2, 1);
% % deri = (derivative(avoidance_force) < 0) * 1; 
% avoidance_force = norm(avoidance_force) * 5;
% % repulsive = 100000 * (from_obs)/(norm(from_obs)^3) .* (derivative(from_obs) < 0);
% 
% if any(lineInterSectsCircle == 1)
%     U(1) = U(1) - avoidance_force;
%     U(2) = U(2) - avoidance_force;
%     U(3) = U(3) - avoidance_force;
% end


%% straight
repulsive = [x;y;z] - obstacle;
force = norm(repulsive)*5;
if any(repulsive(1,1) < -0.1 && repulsive(1,1) > -0.5)
%  	U(1) = U(1) - force/repulsive(3);
	U(2) = U(2) - force/repulsive(2) + 3;
	U(3) = U(3) - force/repulsive(1) + 3;
end

repulsive2 = [x;y;z] - obstacle2;
force2 = norm(repulsive2)*5;
if any(repulsive2(1,1) < -0.1 && repulsive2(1,1) > -0.5)
%  	U(1) = U(1) - force/repulsive(3);
	U(2) = U(2) - force2/repulsive2(2) + 3;
	U(3) = U(3) - force2/repulsive2(1) + 3;
end
dd = repulsive;
end
