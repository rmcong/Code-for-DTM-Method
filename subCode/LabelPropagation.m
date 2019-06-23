%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2016年6月18日 第1次修改 交叉标签传播算法
% 该函数用来对intra和inter显著图的超像素节点进行交叉label propagation处理
% 即利用intra saliency map确定的前景和背景种子点去优化inter saliency map
% 该算法与TIP算法的不同在于V的构建，TIP中因为没有初始显著性图，因此作者直接利用背景先验选定背景种子点，
% 并以邻域内的局部对比方法更新unlabel的节点显著性值
% 本文方法已知初始saliency map（inter或intra），因此不能简单的值选出前景种子点，而应该让初始显著性值参加迭代优化过程

% 参考文献：【2015-TIP】【卢湖川】Inner and Inter Label Propagation Salient Object Detection in the Wild【已读LPS】

% 输入：待优化的图像为sal_sup1，从sal_sup2中选取前景种子点优化sal_sup1
% 输出：sal1_CLP为sal_sup1优化后的结果
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sal_LP = LabelPropagation( sal_sim, adjc, sal_sup, spnum )

% %% 构建关系矩阵
% theta = 10;
% spnum = sup_info1{7};%超像素个数
% dep_vals = sup_info1{2};%深度值列向量
% rgb_vals = sup_info1{1};%RGB向量 spnum×3
% seg_vals = colorspace('Lab<-', rgb_vals);%转换到Lab空间 spnumn*3
% dep_matrix1 = ones(spnum,1) * dep_vals';
% dep_matrix2 = dep_matrix1';
% W_lab =  DistanceZL(seg_vals, seg_vals, 'euclid'); % euclid 公式9
% W_dep =  abs(dep_matrix2 - dep_matrix1); % euclid 公式9
% sal_sim = exp( -theta * normalize( W_lab + lammda1 * W_dep ) );%原文中公式11 描述节点之间的相似性矩阵  spnum×spnum 主对角线元素为1
% 
W = sal_sim.*adjc;% spnum×spnum的affinity矩阵  原文公式10
dd = sum(W,2); % 超像素节点的度 degree
D = sparse(1:spnum,1:spnum,dd);%对角矩阵
P = full(D\W);      % Warning: Matrix is singular to working precision.
%% label propagation

th1 = max(2*mean(sal_sup),0.6);%前景种子点的划分阈值最小为0.6
FG_index = find(sal_sup >= th1);%选出前景种子点标号
th2 = min(mean(sal_sup),0.2);%背景种子点的划分阈值最大为0.2
BG_index = find(sal_sup <= th2);%选出背景种子点标号
sal_index = union(FG_index,BG_index);%所有种子点集合（包括前景和背景）

V = sal_sup;
V(FG_index) = 1;
V(BG_index) = 0;


for ii = 1:spnum
    if isempty(intersect(ii,sal_index)) %条件等于1表明超像素ii不属于种子，是unlabel的数据
        V(ii) = sum( P(ii,:).*V' );
    end
end

sal_LP = normalize(V);

end



