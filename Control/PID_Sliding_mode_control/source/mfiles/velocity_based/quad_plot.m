function h = quad_plot(t, obj)
%
%
h = figure();

index = {1:length(t)};
label = {'x(m)', 'y(m)', 'z(m)', '\phi(rad)', '\theta(rad)', '\psi(rad)'};

for i = 1:6

	eval(sprintf('subplot(61%d);', i));
	plot(t(index{:}), obj.Z_ref(i,index{:}), t(index{:}), obj.output(i,index{:}));
	xlabel('time(s)');
	ylabel(label{i});
	grid on
	
end

subplot(611);
legend('reference', 'state');
set(h, 'Position', [680, 100, 560, 840]);