function [ initSal, rdsp_fusion, RDSP_fusion ] = RDSP( sup_info, m, n, adjc, seg_vals, presal, lammda )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ó������ڼ������Refined Depth Shapr Prior��RDSP�������ͼ�����Լ�ⷽ��
% 2018��6��11�� ��1���޸�
% presal����һ�׶εõ��������Խ��
% insal����ԭʼ�����2D saliency���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spnum = sup_info{7};
dep_vals = sup_info{2};
insal = sup_info{3};
x_vals = sup_info{4}(:,1);%�����ص�x����
y_vals = sup_info{4}(:,2);%�����ص�y����

%% �������ȫ�ֶԱ�
dep_matrix1 = ones(spnum,1) * dep_vals';
dep_matrix2 = dep_matrix1';
dist = sqrt((x_vals*ones(1,spnum) - ones(spnum,1)*x_vals').^2 + (y_vals*ones(1,spnum) - ones(spnum,1)*y_vals').^2);
GCd =  normalize(sum(abs(dep_matrix2 - dep_matrix1).*exp(-10*dist),2));

%% ��ȡ���ӳ��������ӵ�
K1 = 30; % ������ѡ��ĳ�ʼ�����ӵ����
ratio = 0.6; % ����������������ɸѡ��ĸ����ӵ����

% ѡ��������ֵ��ĳ�������Ϊ��ʼ�����ӵ�
sal_sup = 0.5*insal + 0.5*presal;
initSal = get_initSal( lammda,GCd,sal_sup,dep_vals );
initSal = normalize(initSal);
[B1,sal_index1] = sort(initSal,'descend');%��������ֵ���н�������
sal_label1 = sal_index1(1:K1);%ǰK1���ϴ��������ֵ��Ӧ�ĳ����ر��

% �������������һ��ɸѡ  ȷ�����յĸ����ӵ�
sp_x1 = x_vals(sal_label1);
sp_y1 = y_vals(sal_label1);
x_cen = ones(K1,1).*n.*0.5;
y_cen = ones(K1,1).*m.*0.5;
K2 = ceil(K1*ratio);
sp_dis = sqrt((sp_x1 - x_cen).^2 + (sp_y1 - y_cen).^2);
[B2,sp_index] = sort(sp_dis,'ascend');%�Կռ�λ�ý�����������
sal_label2 = sal_label1(sp_index(1:K2));%�������Գ����ر����ѡ��ǰK2������ͼƬ���ĽϽ��ĳ����ر��
th = mean(initSal(sal_label1));
seed_label_all = sal_label2(find(initSal(sal_label2)>=th));
seed_num = length(seed_label_all);

%% ��ɢ��������

RDSP_label = zeros(spnum,seed_num);
RDSP_value = zeros(spnum,seed_num);
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
        neigh_label = Find_Neighbor( cen_label, adjc );% ������
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
    %         DS(find(DS~=0)) = 1;%�������ҵ��������������������ض�Ӧλ����1
    RDSP_label(:,jj) = DS_label;
    RDSP_value(:,jj) = DS_value;
end
%% ����DSP��������ֵ���㣨���DSP�ںϣ�
rdsp_fusion = RDSP_value*initSal(seed_label_all)./seed_num;
RDSP_fusion = normalize(rdsp_fusion);

end

