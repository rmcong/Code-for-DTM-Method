function [coherence,centric] = calDistributionCRM(salSup,Isum,x_vals,y_vals,m,n,spnum,number)
% salSup��ÿ�������������������ص������Գ�������������ظ��� ��ʽ13-15�ķ��ӵ�һ����
% Isum��ÿ�����������������г����صģ�����ֵ*���ظ������ĺ�  ��ʽ13-15�ķ�ĸ
% x_vals,y_vals�������ص�x��y����
% spnum�������ظ���
x_valMat = ones(number,1)*x_vals'; 
y_valMat = ones(number,1)*y_vals';
x0 = (sum(salSup.*x_valMat,2)./Isum)*ones(1,spnum);%ԭ�Ĺ�ʽ14
y0 = (sum(salSup.*y_valMat,2)./Isum)*ones(1,spnum);%ԭ�Ĺ�ʽ15
coherence = sum(salSup.*sqrt((x_valMat-x0).^2 + (y_valMat - y0).^2),2)./Isum;%ԭ�Ĺ�ʽ13 spatial variance

% ��Ϊ������Ŀ������ֵ�ϴ���λ��ͼ����������
bgDis = min([y_vals-1 n-x_vals m-y_vals x_vals-1],[],2);%�������[y_vals-1 n-x_vals m-y_vals x_vals-1]��ÿ�е���Сֵ�����һ��������
bgDis = max(bgDis) - bgDis;
centric = sum(salSup.*(ones(number,1)*(bgDis)'),2)./Isum;%ԭ�Ĺ�ʽ16
end

