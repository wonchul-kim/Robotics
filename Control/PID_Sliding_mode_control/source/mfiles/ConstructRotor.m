function obj = ConstructRotor(Z_ini, X_ref)
%
%
global t

obj = struct('Z', [], 'Z_ref', zeros(6, length(t)+1), 'X_ref', zeros(4, length(t)+1), 'ref', [], 'output', zeros(12, length(t)+1), 'input', []);

obj.Z = Z_ini;
obj.X_ref = X_ref;
obj.ref = X_ref(:,1);
obj.output(:,1) = obj.Z;
obj.input = zeros(4, 1);