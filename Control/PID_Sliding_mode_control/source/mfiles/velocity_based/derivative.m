function dudt = derivative(u, name)
%
%
global dt
persistent prev_u
if isempty(prev_u) || ~isfield(prev_u, name)
	eval(sprintf('prev_u.%s = u.*ones(size(u));', name));
end

eval(sprintf('dudt = (u - prev_u.%s)/dt;', name));
eval(sprintf('prev_u.%s = u;', name));