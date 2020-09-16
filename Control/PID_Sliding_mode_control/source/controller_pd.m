function output = controller_pd(input)

persistent psi_sum x_sum y_sum z_sum
if isempty(psi_sum)
	psi_sum = 0;
	x_sum = 0;
	y_sum = 0;
	z_sum = 0;
end

noise = 0.05;

%% parameters
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

psi_sum = psi_sum + psi;
x_sum = x_sum + x;
y_sum = y_sum + y;
z_sum = z_sum + z;

%%
a = 2e-1;
b = 1e-1;
c = 1e-6;
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
kp_psi = 5;     kd_psi = 5;      ki_psi = 0;
kp_z = 5;       kd_z = 10;       ki_z = 0; 

% input
u1 = kp_z*(z_ref-z)				+	kd_z*(z_dot_ref-z_dot)		 + ki_z*(z_sum_ref - z_sum) + 9.81;
u2 = kp_phi*(phi_ref-phi)		+	kd_phi*(0-phi_dot);
u3 = kp_theta*(theta_ref-theta)	+	kd_theta*(0-theta_dot);
u4 = kp_psi*(psi_ref-psi)		+	kd_psi*(psi_dot_ref-psi_dot) + ki_psi*(psi_sum_ref-psi_sum);

output = [u1;u2;u3;u4;0;0;0;0];
