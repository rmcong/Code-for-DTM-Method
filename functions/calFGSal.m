function FGSal = calFGSal(W_lab,W_dep,COMSal,dist,spnum,theta,num_vals,lammda,dep_vals,lbp_rate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2015/11/9 编写  Diffusion-based Local Contrast

% W_lab：Lab颜色空间的euclid距离 公式9 spnum×spnum
% COMSal：背景紧致性显著图 spnum×1
% dis：超像素之间的距离 spnum×spnum
% sal_lab：原文中公式11 描述节点之间的相似性矩阵 spnum×spnum
% spnum：超像素个数；adjc：邻接矩阵；num_vals：每个超像素包含的像素个数；x_vals,y_vals：超像素的x，y坐标
% lbp_rate：LBP提取的纹理特征
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 确定前景种子点
% % 方法1：加深度修正
FG_th = 0.5;
FG_label = find (COMSal >= FG_th);% 前景种子的标号
dep_th = mean(dep_vals( FG_label ));
label = find ((COMSal >= FG_th) & (dep_vals >= dep_th));
FG_num = numel(label);
% % 方法2：不加深度修正
% FG_th = 0.5;
% label = find (COMSal >= FG_th);% 前景种子的标号
% FG_num = numel(label);
%% 计算前景显著性
% 色彩相似性
col_sim = exp( -theta * normalize( W_lab ) );% 描述节点之间的颜色相似性矩阵  spnum×spnum 主对角线元素为1
% 深度相似性
dep_sim = exp( -theta * normalize( lammda * W_dep ) );% 描述节点之间的深度相似性矩阵  spnum×spnum 主对角线元素为1
% 纹理相似性
tex_sim = Simtexture( lbp_rate );% 描述节点之间的纹理相似性矩阵  spnum×spnum 主对角线元素为1
% 距离约束
distance = exp( -theta * normalize( dist ) );% 描述节点之间的颜色相似性矩阵  spnum×spnum 主对角线元素为1
D_FG = zeros(spnum,1);
for j = 1:spnum
    DD = 0;%初始深度对比度
    for ii = 1:FG_num
        jj = label(ii,1);% 种子超像素标号
        size_seed = num_vals(jj);%种子超像素的大小
        pos_seed = distance(j,jj);
        dep_seed = dep_sim(j,jj);
        color_seed = col_sim(j,jj);
        tex_seed = tex_sim(j,jj);
        DD = DD + (dep_seed * color_seed * tex_seed) * size_seed * pos_seed;
    end
    D_FG(j,1)=DD;
end
FGSal = normalize( D_FG );
end


