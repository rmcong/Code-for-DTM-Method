function [ output ] = LOG( input )
% ���¶�����eΪ�׵�log������ʹ�������0ʱ��log0������NaN��������һ����С��
if input==0
    output=-10^10;
else
    output=log(input);
end

end

