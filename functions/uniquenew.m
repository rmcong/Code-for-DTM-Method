function [ output ] = uniquenew( x )
%求向量的不同的元素（不排序）
for i=1:length(x)-1
    for j=i+1:length(x)
        if x(j)==x(i)
            x(j)=0;%或者其他标识符号。
        end
    end
end
idx=find(x==0);%与前面的标识符号一致。
x(idx)=[];%删除标识项。
output=x;
end

