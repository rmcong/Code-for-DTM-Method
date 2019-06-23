function [comSal] = calCompactness(PNArgb,PNAdep,Sumrgb,Sumdep,x_vals,y_vals,m,n,spnum)
% Diffusion-based Compactness
% salSup：每个超像素与其他超像素的相似性乘以其包含的像素个数 公式13-15的分子的一部分
% depth：超像素级的深度值 spnum*1
% Isum：每个超像素与其他所有超像素的（相似值*像素个数）的和  公式13-15的分母
% x_vals,y_vals：超像素的x，y坐标
% spnum：超像素个数

x_valMat = ones(spnum,1)*x_vals'; 
y_valMat = ones(spnum,1)*y_vals';
ux = (sum(PNArgb.*x_valMat,2)./Sumrgb)*ones(1,spnum);
uy = (sum(PNArgb.*y_valMat,2)./Sumrgb)*ones(1,spnum);
cc = sum(PNArgb.*sqrt((x_valMat-ux).^2 + (y_valMat - uy).^2),2)./(Sumrgb+Sumdep);%spatial variance

% 认为显著性目标的深度值较大且位于图像中心区域
bgDis = min([y_vals-1 n-x_vals m-y_vals x_vals-1],[],2);%求出矩阵[y_vals-1 n-x_vals m-y_vals x_vals-1]的每行的最小值，存成一个列向量
bgDis = max(bgDis) - bgDis;
dc = sum(PNAdep.*(ones(spnum,1)*(bgDis)'),2)./(Sumrgb+Sumdep);%原文公式16

dist = dc + cc;

comSal = dist';
comSal(comSal > mean(comSal)) = mean(comSal);
comSal = 1 - normalize(comSal);
comSal = comSal';
end

