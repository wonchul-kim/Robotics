function drawRotor(output)

global l
r = l/2;

plot3(output(1), output(2), output(3),'ko','MarkerSize',5,'MarkerFaceColor','k');

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

ground = [output(1), output(2), 0]';
body = [output(1), output(2), output(3)]';
x_head = [output(1)+l, output(2), output(3)]';
y_head = [output(1), output(2)+l, output(3)]';
x_tail = [output(1)-l, output(2), output(3)]';
y_tail = [output(1), output(2)-l, output(3)]';

% Draw Frame
drawLine(body, R*(x_head - body) + body, [1 0.3 0.3]);
drawLine(body, R*(y_head - body) + body);
drawLine(body, R*(x_tail - body) + body);
drawLine(body, R*(y_tail - body) + body);

% Draw Rotor
drawCircle3D(R*(x_head - body) + body, R, r);
drawCircle3D(R*(y_head - body) + body, R, r);
drawCircle3D(R*(x_tail - body) + body, R, r);
drawCircle3D(R*(y_tail - body) + body, R, r);

drawLine(body, ground, 'k', 1);

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