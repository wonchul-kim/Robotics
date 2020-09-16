function [ output ] = dynamics( U )

global dt
global g l
global feedback_init

persistent feedback 
if isempty(feedback)
    feedback = feedback_init;
end

u1 = U(1);
u2 = U(2);
u3 = U(3);
u4 = U(4);

x = feedback(1); 
y = feedback(2) ; 
z = feedback(3) ; 
phi = feedback(4);
theta = feedback(5);
psi = feedback(6);

xdot = feedback(7); %u
ydot = feedback(8); %v
zdot = feedback(9); %w
phidot = feedback(10); %p
thetadot = feedback(11); %q
psidot = feedback(12); %r

xddot = u1 * (cos(phi) * sin(theta) * cos(psi) + sin(phi) * sin(psi));
yddot = u1 * (cos(phi) * sin(theta) * sin(psi) - sin(phi) * cos(psi));
zddot = u1 * cos(phi) * cos(theta) - g;
phiddot = u2 * l;
thetaddot = u3 * l;
psiddot = u4;

dfeedback = [xdot   ydot   zdot   phidot   thetadot   psidot ...
            xddot   yddot  zddot  phiddot  thetaddot  psiddot]';
feedback = feedback + dfeedback * dt;

output = feedback;
end

