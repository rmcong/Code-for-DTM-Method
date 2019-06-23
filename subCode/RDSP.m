function [ initSal, rdsp_fusion, RDSP_fusion ] = RDSP( sup_info, m, n, adjc, seg_vals, presal, lammda )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 该程序用于计算基于Refined Depth Shapr Prior（RDSP）的深度图显著性检测方法
% 2018年6月11日 第1次修改
% presal：上一阶段得到的显著性结果
% insal：最原始输入的2D saliency结果
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spnum = sup_info{7};
dep_vals = sup_info{2};
insal = sup_info{3};
x_vals = sup_info{4}(:,1);%超像素的x坐标
y_vals = sup_info{4}(:,2);%超像素的y坐标

%% 计算深度全局对比
dep_matrix1 = ones(spnum,1) * dep_vals';
dep_matrix2 = dep_matrix1';
dist = sqrt((x_vals*ones(1,spnum) - ones(spnum,1)*x_vals').^2 + (y_vals*ones(1,spnum) - ones(spnum,1)*y_vals').^2);
GCd =  normalize(sum(abs(dep_matrix2 - dep_matrix1).*exp(-10*dist),2));

%% 获取种子超像素种子点
K1 = 30; % 显著性选择的初始根种子点个数
ratio = 0.6; % 最终利用中心先验筛选后的根种子点比例

% 选择显著性值大的超像素作为初始根种子点
sal_sup = 0.5*insal + 0.5*presal;
initSal = get_initSal( lammda,GCd,sal_sup,dep_vals );
initSal = normalize(initSal);
[B1,sal_index1] = sort(initSal,'descend');%对显著性值进行降序排列
sal_label1 = sal_index1(1:K1);%前K1个较大的显著性值对应的超像素标号

% 利用中心先验进一步筛选  确定最终的根种子点
sp_x1 = x_vals(sal_label1);
sp_y1 = y_vals(sal_label1);
x_cen = ones(K1,1).*n.*0.5;
y_cen = ones(K1,1).*m.*0.5;
K2 = ceil(K1*ratio);
sp_dis = sqrt((sp_x1 - x_cen).^2 + (sp_y1 - y_cen).^2);
[B2,sp_index] = sort(sp_dis,'ascend');%对空间位置进行升序排列
sal_label2 = sal_label1(sp_index(1:K2));%在显著性超像素标号中选择前K2个距离图片中心较近的超像素标号
th = mean(initSal(sal_label1));
seed_label_all = sal_label2(find(initSal(sal_label2)>=th));
seed_num = length(seed_label_all);

%% 扩散搜索过程

RDSP_label = zeros(spnum,seed_num);
RDSP_value = zeros(spnum,seed_num);
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
        neigh_label = Find_Neighbor( cen_label, adjc );% 列向量
        [seed_dep, neigh_dep, cen_dep] = Find_Depth( cen_label, neigh_label, dep_vals, seed_label );
        [seed_lab, neigh_lab, cen_lab] = Find_Lab( cen_label, neigh_label, seg_vals, seed_label );
        final_neigh_label = Seed_decision( cen_dep, neigh_dep, seed_dep, seed_lab, neigh_lab, cen_lab, neigh_label, final_neigh_ori );
        [seed_dep_fin, neigh_dep_fin, cen_dep_fin] = Find_Depth( cen_label, final_neigh_label, dep_vals, seed_label );
        value = 1 - min(abs(cen_dep_fin - neigh_dep_fin), abs(seed_dep_fin - neigh_dep_fin));
        if length(final_neigh_label) ~= 0
            indictor = 1;
            cen_label = final_neigh_label;
            DS_label(final_neigh_label) = k;
            DS_value(final_neigh_label) = value;
            k = k + 1;
            final_neigh_ori = find(DS_label~=0);
        else
            indictor = 0;
        end
    end
    %         DS(find(DS~=0)) = 1;%将所有找到的满足条件的邻域超像素对应位置置1
    RDSP_label(:,jj) = DS_label;
    RDSP_value(:,jj) = DS_value;
end
%% 基于DSP的显著性值计算（多个DSP融合）
rdsp_fusion = RDSP_value*initSal(seed_label_all)./seed_num;
RDSP_fusion = normalize(rdsp_fusion);

end

