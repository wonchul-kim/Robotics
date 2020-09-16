clear all
clearvars -global

global feedback_init

[ t, X_ref ] = initialize();
feedback_pd = feedback_init;
feedback_sliding = feedback_init;

ref = zeros(6, length(t));                     % to save ref at each time
output_pd = zeros(12, length(t)+1);              % to save final output of PD_controller at each time
output_sliding = zeros(12, length(t)+1);        % to save final output of slinding mode controller ateach time

for i = 1:length(t)
    
    X_ref_i = X_ref(:, i);
    [ U_pd, input_ref] = controller_pd(derivative(X_ref_i), X_ref_i, feedback_pd);
    [ U_sliding, input_ref ] = sliding_mode_control(derivative(X_ref_i), X_ref_i, feedback_sliding);

    feedback_pd = dynamics(U_pd);
    feedback_sliding = dynamics(U_sliding);
    
    ref(:, i) = input_ref;              % [x_ref y_ref z_ref      phi_ref theta_ref psi_ref]'
    output_pd(:, i+1) = feedback_pd;          % [x y z      phi theta psi]'
    output_sliding(:, i+1) = feedback_sliding;
    
end

quad_plot();

