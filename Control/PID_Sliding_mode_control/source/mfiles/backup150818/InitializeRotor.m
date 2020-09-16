function obj = InitializeRotor(obj, Z_ini, X_ref)
%
%
obj.Z = Z_ini;
obj.X_ref = X_ref;
obj.ref = X_ref(:,1);
obj.output(:,1) = obj.Z;