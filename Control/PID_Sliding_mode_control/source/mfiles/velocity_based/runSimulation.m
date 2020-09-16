function arrObj = runSimulation(arrObj)
%
%
global t

N = length(arrObj);

D = arrObj(1).Z(1:3);
for n = 2:N
	D = [D arrObj(n).Z(1:3)];
end

for i = 1:length(t)
	
	%%
	for n = 1:N
		arrObj(n).ref = arrObj(n).X_ref(:,i);
	end
	
	%%
	for n = 1:N
		list = 1:N;
		valid_list = list(list~=n);
		arrObj(n) = controller_sliding(arrObj(n), D(:, valid_list));
	end
	
	%%
	for n = 1:N
		arrObj(n) = dynamics(arrObj(n));
	end
	
	%%
	for n = 1:N
		arrObj(n).Z_ref(:,i)	= arrObj(n).ref;
		arrObj(n).output(:,i+1)	= arrObj(n).Z;
		arrObj(n).F_rep(:,i)	= arrObj(n).repulsive;
		arrObj(n).U(:,i)		= arrObj(n).input;
	end
	
end