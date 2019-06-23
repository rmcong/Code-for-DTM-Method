function [seed_dep, neigh_dep, cen_dep] = Find_Depth( cen_label, neigh_label, dep_vals, seed_label )
% 2016-09-22
% ���룺
% seed_label�������������ĳ����صı��label
% Neigh_label���������ĳ����ض�Ӧ�����е���������label
% dep_vals�����г����ص����ֵ����
% �����
% seed_dep, neigh_dep���������ĳ����ض�Ӧ���������صı�ż���
neigh_num = length(neigh_label);% ����һ�������У����ĳ����صĸ���
seed_dep = ones(neigh_num,1).*mean(dep_vals(seed_label));
cen_dep = ones(neigh_num,1).*mean(dep_vals(cen_label));
neigh_dep = dep_vals(neigh_label);

end

