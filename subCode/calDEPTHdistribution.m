function [coherence,centric] = calDEPTHdistribution(salSup,Isum,x_vals,y_vals,m,n,spnum,number)
% salSup：每个超像素与其他超像素的相似性乘以其包含的像素个数 公式13-15的分子的一部分
% Isum：每个超像素与其他所有超像素的（相似值*像素个数）的和  公式13-15的分母
% x_vals,y_vals：超像素的x，y坐标
% spnum：超像素个数
x_valMat = ones(number,1)*x_vals'; 
y_valMat = ones(number,1)*y_vals';
x0 = (sum(salSup.*x_valMat,2)./Isum)*ones(1,spnum);%原文公式14
y0 = (sum(salSup.*y_valMat,2)./Isum)*ones(1,spnum);%原文公式15
coherence = sum(salSup.*sqrt((x_valMat-x0).^2 + (y_valMat - y0).^2),2)./Isum;%原文公式13 spatial variance

% 认为显著性目标的深度值较大且位于图像中心区域
bgDis = min([y_vals-1 n-x_vals m-y_vals x_vals-1],[],2);%求出矩阵[y_vals-1 n-x_vals m-y_vals x_vals-1]的每行的最小值，存成一个列向量
bgDis = max(bgDis) - bgDis;
centric = sum(salSup.*(ones(number,1)*(bgDis)'),2)./Isum;%原文公式16
end

