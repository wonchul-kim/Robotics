function arrObj = plotSimulation(arrObj)
%
%
global t diameter

N = length(arrObj);

for n = 1:N
	h = quad_plot(t, arrObj(n));
end

figure();
legendTex = {};
for i = 1:N
	for j = i+1:N
		semilogy(t, sqrt(sum((arrObj(i).output(1:3,1:length(t)) - arrObj(j).output(1:3,1:length(t))).^2, 1)));
		hold on;
		
		legendTex{length(legendTex) + 1} = sprintf('d%d%d', i, j);
	end
end
semilogy(t, 2*diameter*ones(size(t)), 'r--', 'LineWidth', 2);
grid on;

set(gcf, 'Position', [748 620 560 200]);
xlabel('time(s)');
ylabel({'distance between' ;'each object (m)'});
xlim([0 10]);
legend(legendTex);