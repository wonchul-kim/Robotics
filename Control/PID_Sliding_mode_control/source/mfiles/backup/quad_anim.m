close all

global dt

minAxes = min(min(output(1:3,:)))-1;
maxAxes = max(max(output(1:3,:)))+1;

obs_ground = [X_obs(1), X_obs(2), 0];
% plot3(0,0,0,'gs','linewidth',3)   % initial point
% plot3(output(end,1), output(end,2), output(end,3),'rd','linewidth',3)   % final point
camera_target = [10, 5, 10];
camera_pos = [-118.2313 -146.9342 67.7336];
camera_angle = 10;

figure(1)
view(3);

for i = 1 : 1 : length(output)
	
	hold off
	% Trajectory
	plot3(output(1, 1:i), output(2, 1:i), zeros(1, i));
	axis([minAxes, maxAxes, minAxes, maxAxes, -1, maxAxes - minAxes]);
	grid on
	hold on
	
	% Obstacle
	plot3(X_obs(1), X_obs(2), X_obs(3), 'r*');
	line([X_obs(1), obs_ground(1)], [X_obs(2), obs_ground(2)], [X_obs(3), obs_ground(3)]);

	set(gca, 'CameraTarget',	camera_target);
	set(gca, 'CameraPosition',	camera_pos);
	set(gca, 'CameraViewAngle', camera_angle);
	
	% Draw Rotor
	drawRotor(output(:,i));
	pause(dt);
	
	camera_target	= get(gca, 'CameraTarget');
	camera_pos		= get(gca, 'CameraPosition');
	camera_angle	= get(gca, 'CameraViewAngle');
	
% 	if getkeywait(0.001) ~= -1
% 		return;
% 	end
	
end

xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
legend('Initial Point', 'Obstacle', 'Quadrotor', 'Heading')
axis equal
