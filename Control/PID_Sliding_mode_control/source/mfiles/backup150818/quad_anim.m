close all

global dt N

for n = 1:N
	eval(sprintf('O%d = R%d.output;', n, n));
	eval(sprintf('T%d = R%d.X_ref;', n, n));
	eval(sprintf('F%d = R%d.F_rep;', n, n));
end

color1 = [0.1, .8, 0.2];
color2 = [.8, 0.5, 0.2];
color3 = [0.3, 0.5, 0.8];
color4 = [1, 0.5, 0.5];

S = sprintf('[O1(1:3,:) ');
for n = 2:N
	S = [S sprintf('O%d(1:3,:) ', n)];
end
S = [S ']'];
D = eval(S);

minAxes = min(min(D));
maxAxes = max(max(D));
minAtt  = min(min(D(3,:)));

% plot3(0,0,0,'gs','linewidth',3)   % initial point
% plot3(output(end,1), output(end,2), output(end,3),'rd','linewidth',3)   % final point
camera_target = [4.3641 4.3641 6.1359];
camera_pos = [-57.4096 -69.1379 74.0774];
camera_angle = 9;

figure(1)
view(3);

for i = 1 : 1 : min(length(O1), length(O2))
	
	hold off
% 	% Ground Trajectory
% 	plot3(O1(1, max(1, i-50):i), O1(2, max(1, i-50):i), zeros(1, i - max(1, i-50) + 1), '--', 'Color', color1);hold on
% 	plot3(O2(1, max(1, i-50):i), O2(2, max(1, i-50):i), zeros(1, i - max(1, i-50) + 1), '--', 'Color', color2);
	
	% Reference Trajectory
	for n = 1:N
		eval(sprintf('plot3(T%d(1, 1:i), T%d(2, 1:i), T%d(3, 1:i), ''Color'', color%d/2);', n, n, n, n));hold on;
	end
	
	% Aerial Trajectory
	for n = 1:N
		eval(sprintf('plot3(O%d(1, 1:i), O%d(2, 1:i), O%d(3, 1:i), ''LineWidth'', 2, ''Color'', color%d);', n, n, n, n));
	end
	
	axis([minAxes-1, maxAxes+1, minAxes-1, maxAxes+1, min(minAtt, -1), maxAxes+1]);
	xlabel('x-axis');
	ylabel('y-axis');
	zlabel('z-axis');
	grid on
	
	% Repulsive Force
	for n = 1:N
		eval(sprintf('quiver3(O%d(1,i), O%d(2,i), O%d(3,i), F%d(1,i), F%d(2,i), F%d(3,i));', n, n, n, n, n, n));
	end
	
% 	% Obstacle
% 	plot3(X_obs(1), X_obs(2), X_obs(3), 'r*');
	
	set(gca, 'CameraTarget',	camera_target);
	set(gca, 'CameraPosition',	camera_pos);
	set(gca, 'CameraViewAngle', camera_angle);
	
	% Draw Rotor
	for n = 1:N
		eval(sprintf('drawRotor(O%d(:,i));', n));
	end
	pause(dt);
	
	camera_target	= get(gca, 'CameraTarget');
	camera_pos		= get(gca, 'CameraPosition');
	camera_angle	= get(gca, 'CameraViewAngle');

% 	if getkeywait(0.001) ~= -1
% 		return;
% 	end

end

% legend('Initial Point', 'Obstacle', 'Quadrotor', 'Heading')
