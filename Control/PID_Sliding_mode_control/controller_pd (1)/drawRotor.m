function drawRotor(output)

global l
r = l*2/5;

plot3(output(1), output(2), output(3),'ko','MarkerSize',5,'MarkerFaceColor','k');
plot3(output(13), output(14), output(15), 'k-', 'lineWidth', 3);
plot
% x_head = {[output(1), output(1)+l], [output(2), output(2)]};
% y_head = {[output(1), output(1)], [output(2), output(2)+l]};
% x_tail = {[output(1), output(1)-l], [output(2), output(2)]};
% y_tail = {[output(1), output(1)], [output(2), output(2)-l]};

rotx = [1 0 0;
	0 cos(output(4)) -sin(output(4));
	0 sin(output(4))  cos(output(4));
	];
roty = [cos(output(5)) 0 sin(output(5));
	0 1 0;
	-sin(output(5)) 0  cos(output(5));
	];
rotz = [cos(output(6)) -sin(output(6)) 0;
	sin(output(6))  cos(output(6)) 0;
	0 0 1;
	];
R = rotx*roty*rotz;

xy_ground = [output(1), output(2), 0]';
yz_ground = [0, output(2), output(3)]';
zx_ground = [output(1), 0, output(3)]';

body = [output(1), output(2), output(3)]';
% x_head = [output(1)+l, output(2), output(3)]';
% y_head = [output(1), output(2)+l, output(3)]';
% x_tail = [output(1)-l, output(2), output(3)]';
% y_tail = [output(1), output(2)-l, output(3)]';

rod2 = [output(1), output(2)-l, output(3)]';
rod3 = [output(1)-l*sqrt(3)/2, output(2)-l/2, output(3)]';
rod4 = [output(1)-l*sqrt(3)/2, output(2)+l/2, output(3)]';
rod5 = [output(1), output(2)+l, output(3)]';
rod6 = [output(1)+l*sqrt(3)/2, output(2)+l/2, output(3)]';
rod7 = [output(1)+l*sqrt(3)/2, output(2)-l/2, output(3)]';

% Draw Frame
% drawLine(body, R*(x_head - body) + body, [1 0.3 0.3]);
% drawLine(body, R*(y_head - body) + body);
% drawLine(body, R*(x_tail - body) + body);
% drawLine(body, R*(y_tail - body) + body);

drawLine(body, R*(rod2 - body) + body);
drawLine(body, R*(rod3 - body) + body);
drawLine(body, R*(rod4 - body) + body);
drawLine(body, R*(rod5 - body) + body);
drawLine(body, R*(rod6 - body) + body, [1 0.3 0.3]);
drawLine(body, R*(rod7 - body) + body, [1 0.3 0.3]);

% Draw Rotor
drawCircle3D(R*(rod2 - body) + body, R, r);
drawCircle3D(R*(rod3 - body) + body, R, r);
drawCircle3D(R*(rod4 - body) + body, R, r);
drawCircle3D(R*(rod5 - body) + body, R, r);
drawCircle3D(R*(rod6 - body) + body, R, r);
drawCircle3D(R*(rod7 - body) + body, R, r);

drawLine(body, xy_ground, 'k', 1);
% drawLine(body, yz_ground, 'k', 1);
% drawLine(body, zx_ground, 'k', 1);

end

function drawLine(X, Y, color, width)

if nargin == 2
	line([X(1), Y(1)], [X(2), Y(2)], [X(3), Y(3)], 'LineWidth', 2);
elseif nargin == 3
	line([X(1), Y(1)], [X(2), Y(2)], [X(3), Y(3)], 'LineWidth', 2, 'Color', color);
else
	line([X(1), Y(1)], [X(2), Y(2)], [X(3), Y(3)], 'LineWidth', width, 'Color', color);
end

end

function drawCircle3D(center, R, radius)

theta = 0:0.01:2*pi;
points = bsxfun(@plus, center, radius*(R(:,1)*cos(theta) + R(:,2)*sin(theta)));
plot3(points(1,:),points(2,:),points(3,:), 'k-');

end