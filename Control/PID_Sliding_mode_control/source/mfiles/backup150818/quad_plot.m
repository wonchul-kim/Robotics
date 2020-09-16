function quad_plot(t, obj)
%
%
figure();

index = {1:length(t)};

for i = 1:6

	eval(sprintf('subplot(61%d);', i));
	plot(t(index{:}), obj.Z_ref(i,index{:}), t(index{:}), obj.output(i,index{:}));
	
	grid on
	
end
