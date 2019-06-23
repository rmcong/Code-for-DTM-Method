function [ DSP_fusion ] = DSP( superpixels1, adjc1, sup_dep1, sal_SACS_all )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 该程序用于计算基于Depth Shapr Prior（DSP）的深度图显著性检测方法
% 2016年11月01日 第1次修改
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spnum = max(superpixels1(:));
[m,n] = size(superpixels1);
% compute the feature (mean color in lab color space) for each superpixels
inds = cell(spnum,1);
[x, y] = meshgrid(1:1:n, 1:1:m);%m×n的矩阵，每行是1~n的数字
x_vals = zeros(spnum,1);
y_vals = zeros(spnum,1);
num_vals = zeros(spnum,1);
for i=1:spnum
    inds{i} = find(superpixels1==i);
    num_vals(i) = length(inds{i});%每个超像素包含像素的个数
    x_vals(i) = sum(x(inds{i}))/num_vals(i);%超像素的x坐标
    y_vals(i) = sum(y(inds{i}))/num_vals(i);%超像素的y坐标
end

%% 获取种子超像素种子点
K1 = 15; K2 = 10;
[B1,sal_index] = sort(sal_SACS_all,'descend');%对显著性值进行降序排列
sal_label = sal_index(1:K1);%前K1个较大的显著性值对应的超像素标号

sp_x = x_vals(sal_label);
sp_y = y_vals(sal_label);
x_cen = ones(K1,1).*n.*0.5;
y_cen = ones(K1,1).*m.*0.5;
sp_dis = sqrt((sp_x - x_cen).^2 + (sp_y - y_cen).^2);
[B2,sp_index] = sort(sp_dis,'ascend');%对空间位置进行升序排列
seed_label_all = sal_label(sp_index(1:K2));%在显著性超像素标号中选择前K2个距离图片中心较近的超像素标号
seed_num = length(seed_label_all);
%% 求得种子超像素节点的中心先验修正的显著性值
sp_x2 = x_vals(seed_label_all);
sp_y2 = y_vals(seed_label_all);
x_cen2 = ones(seed_num,1).*n.*0.5;
y_cen2 = ones(seed_num,1).*m.*0.5;
center_prior = exp(-9*(((sp_x2 - x_cen2)/n).^2+((sp_y2 - y_cen2)/m).^2));
seed_sal_all = sal_SACS_all(seed_label_all).*center_prior;%列向量 种子点个数×1
%% 扩散搜索过程
DSP_label = zeros(spnum,seed_num);
DSP_value = zeros(spnum,seed_num);
for jj = 1:seed_num
    indictor = 1;
    k = 2;
    seed_label = seed_label_all(jj);%种子超像素节点
    cen_label = seed_label;%初始化中心超像素节点
    
    DS_label = zeros(spnum,1);%此种子超像素节点的deph shape label
    DS_value = zeros(spnum,1);%此种子超像素节点的deph shape value
    DS_label(cen_label) = 1;%种子超像素节点的deph shape mask置1
    DS_value(cen_label) = 1;%种子超像素节点的deph shape mask置1
    
    final_neigh_ori = [];
    while (indictor == 1)
        neigh_label = Find_Neighbor( cen_label, adjc1 );% 列向量
        [seed_dep, neigh_dep, cen_dep] = Find_Depth( cen_label, neigh_label, sup_dep1, seed_label );
        final_neigh_label = DEPTH_Panduan( cen_dep, neigh_dep, neigh_label, seed_dep, final_neigh_ori );
        [seed_dep_fin, neigh_dep_fin, cen_dep_fin] = Find_Depth( cen_label, final_neigh_label, sup_dep1, seed_label );
        value = 1 - min(abs(cen_dep_fin - neigh_dep_fin), abs(seed_dep_fin - neigh_dep_fin));
        if length(final_neigh_label) ~= 0
            indictor = 1;
            cen_label = final_neigh_label;
            DS_label(final_neigh_label) = k;
            DS_value(final_neigh_label) = value;
            k = k +1;
            final_neigh_ori = find(DS_label~=0);
        else
            indictor = 0;
        end
    end
    %         DS(find(DS~=0)) = 1;%将所有找到的满足条件的邻域超像素对应位置置1
    DSP_label(:,jj) = DS_label;
    DSP_value(:,jj) = DS_value;
end
%% 基于DSP的显著性值计算（多个DSP融合）
dsp_fusion = DSP_value*seed_sal_all./seed_num;
DSP_fusion = normalize(dsp_fusion);

end

