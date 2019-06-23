function scatterMatrix( input )
% ªÊ÷∆…¢µ„Õº
for i=1:Iy
    hold on
    X=1:Ix;
    Y=input(:,i);
    scatter(X,Y,'*','b');
end

end

