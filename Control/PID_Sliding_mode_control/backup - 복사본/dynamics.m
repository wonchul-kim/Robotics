function output = dynamics(U)

global dt
global g l
global Z_ini

persistent Z
if isempty(Z)
	Z = Z_ini;
end

u1 = U(1);
u2 = U(2);
u3 = U(3);
u4 = U(4);

x			= Z(1);
y			= Z(2);
z			= Z(3);
phi			= Z(4);
theta		= Z(5);
psi			= Z(6);

xdot		= Z(7);
ydot		= Z(8);
zdot		= Z(9);
phidot		= Z(10);
thetadot	= Z(11);
psidot		= Z(12);

xddot		= u1 * (cos(phi)*sin(theta)*cos(psi)+sin(phi)*sin(psi));
yddot		= u1 * (cos(phi)*sin(theta)*sin(psi)-sin(phi)*cos(psi));
zddot		= u1 * cos(phi)*cos(theta)-g;
phiddot		= u2 * l;
thetaddot	= u3 * l;
psiddot		= u4;

dZ = [xdot ydot zdot phidot thetadot psidot xddot yddot zddot phiddot thetaddot psiddot]';
Z = Z + dZ*dt;

output = Z;