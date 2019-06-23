function neigh_label = Find_Neighbor( cen_label, adjc )
% 2016-09-22
% 输入：
% cen_label：所有中心超像素的标号label
% adjc：超像素之间的相邻关系
% 输出：
% Neigh：所有中心超像素对应的邻域超像素的标号集合
cen_num = length(cen_label);% 在这一轮搜索中，中心超像素的个数
neigh_label = [];
for ii = 1:cen_num
    sup_index = cen_label(ii);%处理第ii个中心超像素对应的label
    ring = find(adjc(sup_index,:)==1);%该中心超像素的所有邻域超像素的label
    neigh_label = union(ring,neigh_label);%该邻域label与上面所有中心超像素的邻域label的并集 列向量
end

end

