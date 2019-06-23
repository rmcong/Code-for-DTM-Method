function [seed_dep, neigh_dep, cen_dep] = Find_Depth( cen_label, neigh_label, dep_vals, seed_label )
% 2016-09-22
% 输入：
% seed_label：这组所有中心超像素的标号label
% Neigh_label：这组中心超像素对应的所有的邻域超像素label
% dep_vals：所有超像素的深度值集合
% 输出：
% seed_dep, neigh_dep：所有中心超像素对应的邻域超像素的标号集合
neigh_num = length(neigh_label);% 在这一轮搜索中，中心超像素的个数
seed_dep = ones(neigh_num,1).*mean(dep_vals(seed_label));
cen_dep = ones(neigh_num,1).*mean(dep_vals(cen_label));
neigh_dep = dep_vals(neigh_label);

end

