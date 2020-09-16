clc
clear all
clearvars -global

global t;

Initialize();
arrObj = InitializeArrRotor();

%%
arrObj = addRotor(arrObj,...
	[-10 1 .2 0 0 0 0 0 0 0 0 0]',...
	[5*sin(0.5*t);
	5*cos(0.5*t);
	5*ones(size(t));
	0*ones(size(t))]);

arrObj = addRotor(arrObj,...
	[10 -.5 -.3 0 0 0 0 0 0 0 0 0]',...	
	[8*sin(0.5*t);
	8*cos(0.5*t);
	5*ones(size(t));
	0*ones(size(t))]);

arrObj = addRotor(arrObj,...
	[0.3 -0.2 0 0 0 0 0 0 0 0 0 0]',...	
	[6.5*sin(0.5*t);
	6.5*cos(0.5*t);
	8*ones(size(t));
	0*ones(size(t))]);

% Obstacles
arrObj = addRotor(arrObj,...
	[-.2 5 .2 0 0 0 0 0 0 0 0 0]',...	
	[7*sin(0.5*t);
	0*ones(size(t));
	7 + 7*cos(0.5*t);
	0*ones(size(t))]);

arrObj = addRotor(arrObj,...
	[-.2 -5 .2 0 0 0 0 0 0 0 0 0]',...	
	[8*sin(-0.5*t);
	8*cos(-0.5*t);
	5*ones(size(t));
	0*ones(size(t))]);

% arrObj = addRotor(arrObj,...
% 	[-10 1 .2 0 0 0 0 0 0 0 0 0]',...
% 	[10, .3, .4, 0]);
% 
% arrObj = addRotor(arrObj,...
% 	[10 -.5 -.3 0 0 0 0 0 0 0 0 0]',...	
% 	[-10, -.2, 0, 0]);
% 	
% arrObj = addRotor(arrObj,...
% 	[0.3 -0.2 10 0 0 0 0 0 0 0 0 0]',...	
% 	[0.2, -0.3, -10, 0]);
% 
% arrObj = addRotor(arrObj,...
% 	[-.2 .3 .2 0 0 0 0 0 0 0 0 0]',...	
% 	[-.1, .2, .5, 0]);

arrObj = runSimulation(arrObj);
arrObj = plotSimulation(arrObj);