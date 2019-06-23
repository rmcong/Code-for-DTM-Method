function [ DSP_fusion ] = DSP( superpixels1, adjc1, sup_dep1, sal_SACS_all )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ó������ڼ������Depth Shapr Prior��DSP�������ͼ�����Լ�ⷽ��
% 2016��11��01�� ��1���޸�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spnum = max(superpixels1(:));
[m,n] = size(superpixels1);
% compute the feature (mean color in lab color space) for each superpixels
inds = cell(spnum,1);
[x, y] = meshgrid(1:1:n, 1:1:m);%m��n�ľ���ÿ����1~n������
x_vals = zeros(spnum,1);
y_vals = zeros(spnum,1);
num_vals = zeros(spnum,1);
for i=1:spnum
    inds{i} = find(superpixels1==i);
    num_vals(i) = length(inds{i});%ÿ�������ذ������صĸ���
    x_vals(i) = sum(x(inds{i}))/num_vals(i);%�����ص�x����
    y_vals(i) = sum(y(inds{i}))/num_vals(i);%�����ص�y����
end

%% ��ȡ���ӳ��������ӵ�
K1 = 15; K2 = 10;
[B1,sal_index] = sort(sal_SACS_all,'descend');%��������ֵ���н�������
sal_label = sal_index(1:K1);%ǰK1���ϴ��������ֵ��Ӧ�ĳ����ر��

sp_x = x_vals(sal_label);
sp_y = y_vals(sal_label);
x_cen = ones(K1,1).*n.*0.5;
y_cen = ones(K1,1).*m.*0.5;
sp_dis = sqrt((sp_x - x_cen).^2 + (sp_y - y_cen).^2);
[B2,sp_index] = sort(sp_dis,'ascend');%�Կռ�λ�ý�����������
seed_label_all = sal_label(sp_index(1:K2));%�������Գ����ر����ѡ��ǰK2������ͼƬ���ĽϽ��ĳ����ر��
seed_num = length(seed_label_all);
%% ������ӳ����ؽڵ����������������������ֵ
sp_x2 = x_vals(seed_label_all);
sp_y2 = y_vals(seed_label_all);
x_cen2 = ones(seed_num,1).*n.*0.5;
y_cen2 = ones(seed_num,1).*m.*0.5;
center_prior = exp(-9*(((sp_x2 - x_cen2)/n).^2+((sp_y2 - y_cen2)/m).^2));
seed_sal_all = sal_SACS_all(seed_label_all).*center_prior;%������ ���ӵ������1
%% ��ɢ��������
DSP_label = zeros(spnum,seed_num);
DSP_value = zeros(spnum,seed_num);
for jj = 1:seed_num
    indictor = 1;
    k = 2;
    seed_label = seed_label_all(jj);%���ӳ����ؽڵ�
    cen_label = seed_label;%��ʼ�����ĳ����ؽڵ�
    
    DS_label = zeros(spnum,1);%�����ӳ����ؽڵ��deph shape label
    DS_value = zeros(spnum,1);%�����ӳ����ؽڵ��deph shape value
    DS_label(cen_label) = 1;%���ӳ����ؽڵ��deph shape mask��1
    DS_value(cen_label) = 1;%���ӳ����ؽڵ��deph shape mask��1
    
    final_neigh_ori = [];
    while (indictor == 1)
        neigh_label = Find_Neighbor( cen_label, adjc1 );% ������
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
    %         DS(find(DS~=0)) = 1;%�������ҵ��������������������ض�Ӧλ����1
    DSP_label(:,jj) = DS_label;
    DSP_value(:,jj) = DS_value;
end
%% ����DSP��������ֵ���㣨���DSP�ںϣ�
dsp_fusion = DSP_value*seed_sal_all./seed_num;
DSP_fusion = normalize(dsp_fusion);

end

