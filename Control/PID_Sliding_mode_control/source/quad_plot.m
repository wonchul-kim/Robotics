close all
figure(1)

% axis([-5 15 -5 15 -2 2])
hold on
grid on

minAxes = min(min(output1(:,:)))-1;
maxAxes = max(max(output1(:,:)))+1;

% plot3(0,0,0,'gs','linewidth',3)   % initial point
% plot3(output1(end,1), output1(end,2), output1(end,3),'rd','linewidth',3)   % final point

for i = 1 : 1 : length(output1)
	
	hold off
	plot3(output1(1:i,1), output1(1:i,2), zeros(size(1:i)));
	axis([minAxes, maxAxes, minAxes, maxAxes, 0, maxAxes - minAxes]);
	grid on
	hold on
	drawRotor(output1(i,:));
	pause(0.05);
	
end

xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')
legend('Initial Point', 'Goal Point', 'Quadrotor', 'Heading')
axis equal