function [comSal,cohSal,cenSal] = DiffusionCompact(salSup,Isum,x_vals,y_vals,m,n,spnum,depth,lammda)
% Diffusion-based Compactness
% salSup：每个超像素与其他超像素的相似性乘以其包含的像素个数 公式13-15的分子的一部分
% depth：超像素级的深度值 spnum*1
% Isum：每个超像素与其他所有超像素的（相似值*像素个数）的和  公式13-15的分母
% x_vals,y_vals：超像素的x，y坐标
% spnum：超像素个数

[coherence,centric] = calDistributionCRM(salSup,Isum,x_vals,y_vals,m,n,spnum,spnum);

sigma = 10;% 原文中(1/sigma^2)=10,sigma^2=0.1
dep_factor = exp(-sigma*depth*lammda);

dist = coherence + centric.*dep_factor;

comSal = dist';
comSal(comSal > mean(comSal)) = mean(comSal);
comSal = 1 - normalize(comSal);
comSal = comSal';

cohSal = 1 - normalize(coherence);
cenSal = 1 - normalize(centric.*dep_factor);

