function [ U, X_ref ] = controller_pd( X_dot_ref, X_ref, feedback )
%UNTITLED5 이 함수의 요약 설명 위치
%   자세한 설명 위치

%% inputs for plant
% input (1)
x_dot_ref		= X_dot_ref(1);
y_dot_ref		= X_dot_ref(2);
z_dot_ref		= X_dot_ref(3);
psi_dot_ref		= X_dot_ref(4);

x_ref			= X_ref(1);
y_ref			= X_ref(2);
z_ref			= X_ref(3);
psi_ref			= X_ref(4);

% input (2) ~ from feedback
x				= feedback(1);
y				= feedback(2);
z				= feedback(3);
phi				= feedback(4);
theta			= feedback(5);
psi				= feedback(6);

x_dot			= feedback(7);
y_dot			= feedback(8);
z_dot			= feedback(9);
phi_dot			= feedback(10);
theta_dot		= feedback(11);
psi_dot			= feedback(12);

a = 2e-1;
b = 1e-1;
phi_ref = a*(y_dot_ref - y_dot) + b*(y_ref - y);
theta_ref = a*(x_dot_ref - x_dot) + b*(x_ref - x);

convert = [cos(psi) sin(psi);sin(psi) -cos(psi)]*[theta_ref;phi_ref]; % from body to inertia space
theta_ref = convert(1);
phi_ref = convert(2);

if abs(theta_ref) + abs(phi_ref) > 0.6
    theta_ref = theta_ref / (abs(theta_ref) + abs(phi_ref)) * 0.6;
    phi_ref = phi_ref / (abs(theta_ref) + abs(phi_ref)) * 0.6;
end


%% pd contorller
% Gain
kp_phi = 50;                 kd_phi = 20;
kp_theta = 50;               kd_theta = 15;
kp_psi = 5;                  kd_psi = 5;
kp_z = 5;                    kd_z = 10;                       KI_z = 0; 

I_ze = 0;
ze = z_ref-z;
I_ze = I_ze+ze;

% inputs for dynamics
u1 = kp_z * (z_ref - z)                +  kd_z * (z_dot_ref - z_dot)   ...
                                       +  KI_z * (I_ze) + 9.81;
u2 = kp_phi * (phi_ref - phi)          +  kd_phi * (-phi_dot);
u3 = kp_theta * (theta_ref - theta)    +  kd_theta * (-theta_dot);
u4 = kp_psi * (psi_ref - psi)          +  kd_psi * (psi_dot_ref - psi_dot);

U = [u1,u2,u3,u4];
X_ref = [x_ref y_ref z_ref      phi_ref theta_ref psi_ref]';

end

