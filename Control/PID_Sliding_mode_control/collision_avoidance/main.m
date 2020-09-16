clear all
clearvars -global

global feedback_init

[ t, X_ref ] = initialize();
feedback_pd = feedback_init;
feedback_sliding = feedback_init;

% obstacle = [10, 10, 5]';
obstacle = [3.542, -1.899, 5]';
obstacle2 = [12.78, 1.06, 5]';


ref = zeros(6, length(t));                     % to save ref at each time
% zeros will be in the 1st column
% output_pd = zeros(12, length(t)+1);              % to save final output of PD_controller at each time
output_sliding = zeros(12, length(t)+1);        % to save final output of slinding mode controller ateach time
ddd = zeros(3,length(t));
for i = 1:length(t)
    
    X_ref_i = X_ref(:, i);
%     [ U_pd, input_ref] = controller_pd(derivative(X_ref_i), X_ref_i, feedback_pd);
    [ U_sliding, input_ref, dd ] = sliding_mode_control(derivative(X_ref_i), X_ref_i, feedback_sliding, obstacle, obstacle2);

%     feedback_pd = dynamics(U_pd);
    feedback_sliding = dynamics(U_sliding);
    
    ref(:, i) = input_ref;              % [x_ref y_ref z_ref      phi_ref theta_ref psi_ref]'
%     output_pd(:, i+1) = feedback_pd;          % [x y z      phi theta psi]'
    output_sliding(:, i+1) = feedback_sliding;
    ddd(:,i) = dd;
end

quad_plot();

