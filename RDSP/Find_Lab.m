function [seed_lab, neigh_lab, cen_lab] = Find_Lab( cen_label, neigh_label, seg_vals, seed_label )
% 2018-06-08
% ���룺
% seed_label�������������ĳ����صı��label  ֻ��һ��
% neigh_label���������ĳ����ض�Ӧ�����е���������label
% cen_albel����һ����������г�����  ���ܴ��ڶ��
% seg_vals�����г����ص����ֵ����
% �����
% seed_lab, neigh_lab���������ĳ����ض�Ӧ���������صı�ż���
neigh_num = length(neigh_label);% ����һ�������У����ĳ����صĸ���
seed_lab = ones(neigh_num,1)*seg_vals(seed_label,:);
if length(cen_label) == 1
    cen_lab = ones(neigh_num,1)*seg_vals(cen_label,:);%���ֻ��һ�����ӵ�����ƽ��   
else    
    cen_lab = ones(neigh_num,1)*mean(seg_vals(cen_label,:));
end
neigh_lab = seg_vals(neigh_label,:);

end

