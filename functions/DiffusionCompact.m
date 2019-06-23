function [comSal,cohSal,cenSal] = DiffusionCompact(salSup,Isum,x_vals,y_vals,m,n,spnum,depth,lammda)
% Diffusion-based Compactness
% salSup��ÿ�������������������ص������Գ�������������ظ��� ��ʽ13-15�ķ��ӵ�һ����
% depth�������ؼ������ֵ spnum*1
% Isum��ÿ�����������������г����صģ�����ֵ*���ظ������ĺ�  ��ʽ13-15�ķ�ĸ
% x_vals,y_vals�������ص�x��y����
% spnum�������ظ���

[coherence,centric] = calDistributionCRM(salSup,Isum,x_vals,y_vals,m,n,spnum,spnum);

sigma = 10;% ԭ����(1/sigma^2)=10,sigma^2=0.1
dep_factor = exp(-sigma*depth*lammda);

dist = coherence + centric.*dep_factor;

comSal = dist';
comSal(comSal > mean(comSal)) = mean(comSal);
comSal = 1 - normalize(comSal);
comSal = comSal';

cohSal = 1 - normalize(coherence);
cenSal = 1 - normalize(centric.*dep_factor);

