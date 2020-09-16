close all

global dt

output = output_sliding;
obs_ground = [obstacle(1), obstacle(2), 0];   
obs_ground2 = [obstacle2(1), obstacle2(2), 0];   


minAxes = min(min(output(1:3,:)))-1;            % x, y, z
maxAxes = max(max(output(1:3,:)))+1;            % x, y, z

plot3(0,0,0,'gs','linewidth',3)   % initial point
plot3(output(end,1), output(end,2), output(end,3),'rd','linewidth',3)   % final point

camera_target = [4.8040 4.8040 10.7207];
camera_pos = [-98.4482 -119.6320 123.3474];
camera_angle = 9.9999;

figure(1)
view(3);

for i = 1 : 1 : length(ref)
	
	hold off
	% Trajectory
	plot3(output(1, 1:i), output(2, 1:i), zeros(1, i), 'r-', 'linewidth', 1);
    hold on
    plot3(ref(1, 1:i), ref(2,1:i), zeros(1,i), 'b--', 'linewidth', 2);
	axis([minAxes, maxAxes, minAxes, maxAxes, -1, maxAxes - minAxes]);
	grid on
	hold on
	
	% Obstacle
	plot3(obstacle(1), obstacle(2), obstacle(3), 'r.', 'markerSize', 15);
	line([obstacle(1), obs_ground(1)], [obstacle(2), obs_ground(2)], [obstacle(3), obs_ground(3)]);
    plot3(obstacle2(1), obstacle2(2), obstacle2(3), 'r.', 'markerSize', 15);
	line([obstacle2(1), obs_ground2(1)], [obstacle2(2), obs_ground2(2)], [obstacle2(3), obs_ground2(3)]);
    
	set(gca, 'CameraTarget',	camera_target);
	set(gca, 'CameraPosition',	camera_pos);
	set(gca, 'CameraViewAngle', camera_angle);
	
	% Draw Rotor
	drawRotor(output(:,i));
	pause(dt);
	
% 	camera_target	= get(gca, 'CameraTarget');
% 	camera_pos		= get(gca, 'CameraPosition');
% 	camera_angle	= get(gca, 'CameraViewAngle');
	
% 	if getkeywait(0.001) ~= -1
% 		return;
% 	end
	
end

xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
legend('current path', 'reference path', 'Quadrotor')
axis equal
