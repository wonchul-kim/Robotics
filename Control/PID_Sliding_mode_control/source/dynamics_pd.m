function output=dynamics_pd(input)

global g l

u1 = input(1);
u2 = input(2);
u3 = input(3);
u4 = input(4);

x = input(5);
y = input(6);
z = input(7);
phi = input(8);
theta = input(9);
psi = input(10);

u = input(11);
v = input(12);
w = input(13);
p = input(14);
q = input(15);
r = input(16);

xdot = u;
ydot = v;
zdot = w;
xddot = u1*(cos(phi)*sin(theta)*cos(psi)+sin(phi)*sin(psi));
yddot = u1*(cos(phi)*sin(theta)*sin(psi)-sin(phi)*cos(psi));
zddot = u1*cos(phi)*cos(theta)-g;
% xddot = u1*sin(theta);
% yddot = -u1*sin(phi);
% zddot = u1*cos(phi)*cos(theta)-g;

phidot = p;
thetadot = q;
psidot = r;

phiddot = u2*l;
thetaddot = u3*l;
psiddot = u4;

output=[xdot ydot zdot phidot thetadot psidot xddot yddot zddot phiddot thetaddot psiddot];