function [comSal] = calCompactness(PNArgb,PNAdep,Sumrgb,Sumdep,x_vals,y_vals,m,n,spnum)
% Diffusion-based Compactness
% salSup��ÿ�������������������ص������Գ�������������ظ��� ��ʽ13-15�ķ��ӵ�һ����
% depth�������ؼ������ֵ spnum*1
% Isum��ÿ�����������������г����صģ�����ֵ*���ظ������ĺ�  ��ʽ13-15�ķ�ĸ
% x_vals,y_vals�������ص�x��y����
% spnum�������ظ���

x_valMat = ones(spnum,1)*x_vals'; 
y_valMat = ones(spnum,1)*y_vals';
ux = (sum(PNArgb.*x_valMat,2)./Sumrgb)*ones(1,spnum);
uy = (sum(PNArgb.*y_valMat,2)./Sumrgb)*ones(1,spnum);
cc = sum(PNArgb.*sqrt((x_valMat-ux).^2 + (y_valMat - uy).^2),2)./(Sumrgb+Sumdep);%spatial variance

% ��Ϊ������Ŀ������ֵ�ϴ���λ��ͼ����������
bgDis = min([y_vals-1 n-x_vals m-y_vals x_vals-1],[],2);%�������[y_vals-1 n-x_vals m-y_vals x_vals-1]��ÿ�е���Сֵ�����һ��������
bgDis = max(bgDis) - bgDis;
dc = sum(PNAdep.*(ones(spnum,1)*(bgDis)'),2)./(Sumrgb+Sumdep);%ԭ�Ĺ�ʽ16

dist = dc + cc;

comSal = dist';
comSal(comSal > mean(comSal)) = mean(comSal);
comSal = 1 - normalize(comSal);
comSal = comSal';
end

