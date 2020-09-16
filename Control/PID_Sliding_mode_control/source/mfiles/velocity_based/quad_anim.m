close all

N = length(arrObj);

for n = 1:N
	O{n} = arrObj(n).output;
	T{n} = arrObj(n).X_ref;
	F{n} = arrObj(n).F_rep / diag(sqrt(sum((arrObj(n).F_rep + eps).^2, 1)));
% 	eval(sprintf('F%d = R%d.F_rep;', n, n));
end

color = cell(1, N);
for n = 1:N
	color{n} = min(rand(1, 3) + 0.3, 1);
	if norm(color{n}) > 1.38
% 		color{n} = color{n}/norm(color{n})*1.38;
		color{n} = color{n}/norm(color{n})*1;
	end
end

color = {[1 0.3 0.3], [0.3 0.8 0.3], [0.3 0.3 1], [0.8 0.5 0.1], [0.7 , 0.1, 0.6]};

D = O{1}(1:3,:);
for n = 2:N
	D = [D O{n}(1:3,:)];
end

minX	= min(min(D(1,:)));
maxX	= max(max(D(1,:)));
minY	= min(min(D(2,:)));
maxY	= max(max(D(2,:)));
minAtt  = min(min(D(3,:)));
maxAtt  = max(max(D(3,:)));

% plot3(0,0,0,'gs','linewidth',3)   % initial point
% plot3(output(end,1), output(end,2), output(end,3),'rd','linewidth',3)   % final point
camera_target = [4.3641 4.3641 6.1359];
camera_pos = [-57.4096 -69.1379 74.0774];
camera_angle = 9;

x = (minX-1: 0.5: maxX+1) + 0.25;
y = (minY-1: 0.5: maxY+1) + 0.25;
[X, Y] = meshgrid(x, y);
GND = zeros(size(X));

figure(1)
view(3);
% writerObj = VideoWriter('animation.avi');
% open(writerObj);

for i = 1 : 4 : min([length(O{1}), length(T{1}), length(F{1})])
	
	hold off
	
	for j = [minX-1, maxX+1]
		for k = [minY-1, maxY+1]
			for m = [minAtt-1, maxAtt+1]
				plot3(j, k, m);hold on;
			end
		end
	end
% 	% Ground Trajectory
% 	plot3(O1(1, max(1, i-50):i), O1(2, max(1, i-50):i), zeros(1, i - max(1, i-50) + 1), '--', 'Color', color1);hold on
% 	plot3(O2(1, max(1, i-50):i), O2(2, max(1, i-50):i), zeros(1, i - max(1, i-50) + 1), '--', 'Color', color2);
	mesh(X, Y, GND, 'facealpha', 0.2, 'edgealpha', 0.2);
	
% 	% Reference Trajectory
% 	for n = 1:N
% 		eval(sprintf('plot3(T%d(1, 1:i), T%d(2, 1:i), T%d(3, 1:i), ''Color'', color{%d} * 0.7);', n, n, n, n));
% 	end
	
	% Aerial Trajectory
	for n = 1:N
		h{n} = plot3(O{n}(1, 1:i), O{n}(2, 1:i), O{n}(3, 1:i), 'LineWidth', 2, 'Color', color{n});
	end
	
% 	% Attitude Trajectory
% 	for n = 1:N
% 		for m = 1:10:i
% 			bool = O{n}(3, m) > 0;
% 			if bool
% 				style = '-';
% 			else
% 				style = ':';
% 			end
% 			line([O{n}(1, m),O{n}(1, m)], [O{n}(2, m), O{n}(2, m)], [O{n}(3, m), 0], 'LineWidth', 1, 'Color', 'k', 'LineStyle', style);
% 		end
% 	end
	
	% Repulsive Force
	for n = 1:N
		quiver3(O{n}(1,i), O{n}(2,i), O{n}(3,i), F{n}(1,i), F{n}(2,i), F{n}(3,i), 'Color', color{n} * 0.7);
	end
	
	% Axis
	axis([minX-1, minX+1, minY-1, minY+1, minAtt-1, maxAtt+1]);
	axis equal
	
	xlabel('x (m)');
	ylabel('y (m)');
	zlabel('z (m)');
	grid on
	
% 	% Obstacle
% 	plot3(X_obs(1), X_obs(2), X_obs(3), 'r*');
	
	set(gca, 'CameraTarget',	camera_target);
	set(gca, 'CameraPosition',	camera_pos);
	set(gca, 'CameraViewAngle', camera_angle);
	
	% Draw Rotor
	for n = 1:N
		drawRotor(O{n}(:,i));
	end
	
	drawnow;
	if i == 1
		pause;
	end
	
	camera_target	= get(gca, 'CameraTarget');
	camera_pos		= get(gca, 'CameraPosition');
	camera_angle	= get(gca, 'CameraViewAngle');

% 	frame = getframe;
% 	writeVideo(writerObj, frame);

end

% close(writerObj);
% legend('Initial Point', 'Obstacle', 'Quadrotor', 'Heading')
obj = {};
for n = 1:N
	eval(sprintf('obj = [obj ''obj%d''];', n));
end
legend([h{:}], obj);
