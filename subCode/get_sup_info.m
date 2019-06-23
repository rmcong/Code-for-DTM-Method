%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2016��5��27��
% �ú���������ȡͼƬ�����ؽڵ�ĸ�����Ϣ
% ���룺
% superpixels�������صı����Ϣ
% input_vals, depth, sin_sal������ͼ���rgb��Ϣ�������Ϣ�͵�ͼ������
% ScaleH, ScaleW��ͼƬԤ��Ĵ�С
% �����
% sup_info��cell���飬������������������ԣ�����ɫ����ȡ�λ�á��������������ͼ������ֵ���Լ���ͼ���г���������
% spnum/agjc�������ص�������������Ϣ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ sup_info, adjc, inds] = get_sup_info( superpixels, input_vals, depth, sin_sal, m, n )

spnum = max(superpixels(:));
STATS = regionprops(superpixels, 'all');%�õ������ر�ž�������������������������ġ������ȡ�
adjc = calAdjacentMatrix(superpixels,spnum);

sup_info = cell(7,1);
sup_info{1} = zeros(spnum,3);%RGB��ɫ��Ϣ
sup_info{2} = zeros(spnum,1);%�����Ϣ
sup_info{3} = zeros(spnum,1);%��ͼ������
sup_info{4} = zeros(spnum,2);%λ����Ϣ
sup_info{5} = zeros(spnum,1);%�����ش�Сarea
sup_info{6} = zeros(spnum,1);%�������������ظ���
sup_info{7} = spnum;%��ͼ�����ظ���

inds = cell(spnum,1);
[x, y] = meshgrid(1:1:n, 1:1:m);%m��n�ľ���ÿ����1~n������

for i=1:spnum
    inds{i} = find(superpixels==i);% �����������Ӧ�����ص���
    sup_info{1}(i,:) = mean(input_vals(inds{i},:),1);%ÿ�������ص�ƽ����ɫֵ spnum��3
    sup_info{2}(i,:) = mean(depth(inds{i}));%ÿ�������ص�ƽ�����ֵ spnum��1
    sup_info{3}(i,:) = mean(sin_sal(inds{i}));%ÿ�������ص�ƽ����ͼ������ֵ spnum��1
    sup_info{5}(i,:) = STATS(i).Area;
    sup_info{6}(i,:) = length(inds{i});%ÿ�������ذ������صĸ���
    sup_info{4}(i,1) = sum(x(inds{i}))/sup_info{6}(i,:);%�����ص�x����
    sup_info{4}(i,2) = sum(y(inds{i}))/sup_info{6}(i,:);%�����ص�y����
end

end

