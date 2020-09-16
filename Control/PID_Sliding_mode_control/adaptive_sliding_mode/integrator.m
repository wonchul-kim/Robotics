function Sudt = integrator(dudt, initial)

global dt

name = inputname(1);

if nargin == 1            % integrator()의 입력값의 개수
	initial = 0;
end

persistent prev_u
if isempty(prev_u) || ~isfield(prev_u, name)
	eval(sprintf('prev_u.%s = %f*ones(size(dudt));', name, initial));
end

eval(sprintf('Sudt = prev_u.%s + dudt*dt;', name));
eval(sprintf('prev_u.%s = Sudt;', name));