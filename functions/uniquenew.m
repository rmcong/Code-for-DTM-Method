function [ output ] = uniquenew( x )
%�������Ĳ�ͬ��Ԫ�أ�������
for i=1:length(x)-1
    for j=i+1:length(x)
        if x(j)==x(i)
            x(j)=0;%����������ʶ���š�
        end
    end
end
idx=find(x==0);%��ǰ��ı�ʶ����һ�¡�
x(idx)=[];%ɾ����ʶ�
output=x;
end

