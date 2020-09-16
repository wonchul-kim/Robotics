function arrObj = addRotor(arrObj, Z_ini, X_ref)
%
%

N = length(arrObj) + 1;

X_ref = parseRef(X_ref);

arrObj(N).Z = Z_ini;
arrObj(N).X_ref = X_ref;
arrObj(N).ref = X_ref(:,1);
arrObj(N).output(:,1) = Z_ini;
arrObj(N).input = zeros(4, 1);
arrObj(N).id = N;
arrObj(N).repulsive = [];

end

function out = parseRef(X_ref)
%
%

global t

if numel(X_ref) == 4
	out(1, 1:length(t)) = X_ref(1);
	out(2, 1:length(t)) = X_ref(2);
	out(3, 1:length(t)) = X_ref(3);
	out(4, 1:length(t)) = X_ref(4);
else
	out = X_ref;
end

end