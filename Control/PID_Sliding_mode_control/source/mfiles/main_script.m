
clear all
clearvars -global

global N
global diameter

t = Initialize();

%%
% R1 = ConstructRotor([0 0 0 0 0 0 0 0 0 0 0 0]',...
% 	[5*cos(0.2*t);...
% 	5*sin(0.2*t);...
% 	5*ones(size(t));...
% 	(0.2*t + pi).*ones(size(t));...
% 	]);
% 
% R2 = ConstructRotor([10 0 0 0 0 0 0 0 0 0 0 0]',...	
% 	[5*cos(-0.25*t);...
% 	5*sin(-0.2*t);...
% 	5*ones(size(t));...
% 	(0.1*t + pi).*ones(size(t));...
% 	]);

R1 = ConstructRotor([-10 1 .2 0 0 0 0 0 0 0 0 0]',...
	[10*ones(size(t));...
	.3*ones(size(t));...
	.4*ones(size(t));...
	0*ones(size(t));...
	]);

R2 = ConstructRotor([10 -.5 -.3 0 0 0 0 0 0 0 0 0]',...	
	[-10*ones(size(t));...
	-.2*ones(size(t));...
	0*ones(size(t));...
	0*ones(size(t));...
	]);
	
R3 = ConstructRotor([0.3 -0.2 10 0 0 0 0 0 0 0 0 0]',...	
	[0.2*ones(size(t));...
	-0.3*ones(size(t));...
	-10*ones(size(t));...
	0*ones(size(t));...
	]);

R4 = ConstructRotor([-.2 .3 .2 0 0 0 0 0 0 0 0 0]',...	
	[-.1*ones(size(t));...
	.2*ones(size(t));...
	.5*ones(size(t));...
	0*ones(size(t));...
	]);

list = 1:N;
S = sprintf('[R1.Z(1:3) ');
for n = 2:N
	S = [S sprintf('R%d.Z(1:3) ', n)];
end
S = [S ']'];

for i = 1:length(t)
	
	%%
	for n = 1:N
		eval(sprintf('R%d.ref = R%d.X_ref(:,i);', n, n));
	end
	
	%%
	D = eval(S);
	for n = 1:N
		valid_list = list(list~=n);
		eval(sprintf('R%d = controller_sliding(R%d, D(:, valid_list));', n, n));
	end
	
	%%
	for n = 1:N
		eval(sprintf('R%d = dynamics(R%d);', n, n));
	end
	
	%%
	for n = 1:N
		eval(sprintf('R%d.Z_ref(:,i)	= R%d.ref;', n, n));
		eval(sprintf('R%d.output(:,i+1)	= R%d.Z;', n, n));
		eval(sprintf('R%d.F_rep(:,i)	= R%d.repulsive;', n, n));
		eval(sprintf('R%d.U(:,i)		= R%d.input;', n, n));
	end
	
end

for n = 1:N
	eval(sprintf('h = quad_plot(t, R%d);', n));
end

figure();
legendTex = {};
for i = 1:N
	for j = i+1:N
		eval(sprintf('semilogy(t, sqrt(sum((R%d.output(1:3,1:length(t)) - R%d.output(1:3,1:length(t))).^2, 1)));', i, j));
% 		eval(sprintf('plot(t, sqrt(sum((R%d.output(1:3,1:length(t)) - R%d.output(1:3,1:length(t))).^2, 1)));', i, j));
		hold on;
		
		legendTex{length(legendTex) + 1} = sprintf('d%d%d', i, j);
	end
end
semilogy(t, 2*diameter*ones(size(t)), 'r--', 'LineWidth', 2);
% plot(t, 2*diameter*ones(size(t)), 'r--', 'LineWidth', 2);
grid on;

set(gcf, 'Position', [748 620 560 200]);
xlabel('time(s)');
ylabel({'distance between' ;'hexarotors (m)'});
xlim([0 10]);
legend(legendTex);