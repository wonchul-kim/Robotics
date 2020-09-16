clear all
clearvars -global

global feedback_init

[ t, X_ref ] = initialize();
feedback = feedback_init;

ref = zeros(6, length(t)+1);            % to save ref at each time
output = zeros(12, length(t)+1);        % to save final output at each time

for i = 1:length(t)
    
    X_ref_i = X_ref(:, i);
    [ U, input_ref ] = controller_pd(derivative(X_ref_i), X_ref_i, feedback);
    
    feedback = dynamics(U);
    
    ref(:, i) = input_ref;
    output(:, i+1) = feedback;
    
end

quad_plot();
quad_video(output, ref)
