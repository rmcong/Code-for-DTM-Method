function neigh_label = Find_Neighbor( cen_label, adjc )
% 2016-09-22
% ���룺
% cen_label���������ĳ����صı��label
% adjc��������֮������ڹ�ϵ
% �����
% Neigh���������ĳ����ض�Ӧ���������صı�ż���
cen_num = length(cen_label);% ����һ�������У����ĳ����صĸ���
neigh_label = [];
for ii = 1:cen_num
    sup_index = cen_label(ii);%�����ii�����ĳ����ض�Ӧ��label
    ring = find(adjc(sup_index,:)==1);%�����ĳ����ص������������ص�label
    neigh_label = union(ring,neigh_label);%������label�������������ĳ����ص�����label�Ĳ��� ������
end

end

