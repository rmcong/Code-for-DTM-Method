function [seed_lab, neigh_lab, cen_lab] = Find_Lab( cen_label, neigh_label, seg_vals, seed_label )
% 2018-06-08
% 输入：
% seed_label：这组所有中心超像素的标号label  只有一个
% neigh_label：这组中心超像素对应的所有的邻域超像素label
% cen_albel：上一步求出的所有超像素  可能存在多个
% seg_vals：所有超像素的深度值集合
% 输出：
% seed_lab, neigh_lab：所有中心超像素对应的邻域超像素的标号集合
neigh_num = length(neigh_label);% 在这一轮搜索中，中心超像素的个数
seed_lab = ones(neigh_num,1)*seg_vals(seed_label,:);
if length(cen_label) == 1
    cen_lab = ones(neigh_num,1)*seg_vals(cen_label,:);%如果只有一个种子点则不求平均   
else    
    cen_lab = ones(neigh_num,1)*mean(seg_vals(cen_label,:));
end
neigh_lab = seg_vals(neigh_label,:);

end

