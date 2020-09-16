function Sudt = integrator(dudt, name, initial)
%
%
global dt
if nargin == 2
	initial = 0;
end
persistent prev_u
if isempty(prev_u) || ~isfield(prev_u, name)
	eval(sprintf('prev_u.%s = initial.*ones(size(dudt));', name));
end

eval(sprintf('Sudt = prev_u.%s + dudt*dt;', name));
eval(sprintf('prev_u.%s = Sudt;', name));