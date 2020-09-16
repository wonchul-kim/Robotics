function quad_video(in, ref)

global dt

output = in;

minAxes = min(min(output(1:3,:)))-1;            % x, y, z
maxAxes = max(max(output(1:3,:)))+1;            % x, y, z

plot3(0,0,0,'gs','linewidth',3)   % initial point
plot3(output(end,1), output(end,2), output(end,3),'rd','linewidth',3)   % final point
camera_target = [5, 5, 10];
camera_pos = [-118.2313 -146.9342 67.7336];
camera_angle = 10;

figure()
view(3);

for i = 1 : 1 : length(ref)
	
	hold off
	% Trajectory
	plot3(output(1, 1:i), output(2, 1:i), zeros(1, i), 'r-', 'linewidth', 1.5);
    hold on
    plot3(ref(1, 1:i), ref(2,1:i), zeros(1,i), 'b--', 'linewidth', 3);
	axis([minAxes, maxAxes, minAxes, maxAxes, -1, maxAxes - minAxes]);
	grid on
	hold on
	
	% Obstacle
% 	plot3(X_obs(1), X_obs(2), X_obs(3), 'r*');
	
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

end