function scatterMatrix( input )
% ����ɢ��ͼ
for i=1:Iy
    hold on
    X=1:Ix;
    Y=input(:,i);
    scatter(X,Y,'*','b');
end

end

