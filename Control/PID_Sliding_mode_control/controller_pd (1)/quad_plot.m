
figure();

index = {1:1000};

for i = 1:6
    eval(sprintf('subplot(61%d);', i));
    plot(t(index{:}), ref(i,index{:}), t(index{:}), output(i,index{:}));
    
    grid on
end


    