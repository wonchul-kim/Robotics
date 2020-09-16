
global dt T

figure();

index = {1:T/dt};

for i = 1:6
    eval(sprintf('subplot(61%d);', i));
%     plot(t(index{:}), ref(i,index{:}),'k-', t(index{:}), output_pd(i,index{:}), 'b-', t(index{:}), output_sliding(i,index{:}), 'r-');
    plot(t(index{:}), ref(i,index{:}), 'b-', t(index{:}), output_sliding(i,index{:}), 'r-');

    grid on
end
    figure();
    plot(t(index{:}), ddd(1, index{:}));

