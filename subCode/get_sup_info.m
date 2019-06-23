%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2016年5月27日
% 该函数用来获取图片超像素节点的各种信息
% 输入：
% superpixels：超像素的标号信息
% input_vals, depth, sin_sal：输入图像的rgb信息，深度信息和单图显著性
% ScaleH, ScaleW：图片预设的大小
% 输出：
% sup_info：cell数组，包含超像素区域的特性，如颜色、深度、位置、面积、个数、单图显著性值，以及该图所有超像素总数
% spnum/agjc：超像素的总数、相邻信息
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ sup_info, adjc, inds] = get_sup_info( superpixels, input_vals, depth, sin_sal, m, n )

spnum = max(superpixels(:));
STATS = regionprops(superpixels, 'all');%得到超像素标号矩阵的所有属性特征，包括质心、个数等。
adjc = calAdjacentMatrix(superpixels,spnum);

sup_info = cell(7,1);
sup_info{1} = zeros(spnum,3);%RGB颜色信息
sup_info{2} = zeros(spnum,1);%深度信息
sup_info{3} = zeros(spnum,1);%单图显著性
sup_info{4} = zeros(spnum,2);%位置信息
sup_info{5} = zeros(spnum,1);%超像素大小area
sup_info{6} = zeros(spnum,1);%超像素区域像素个数
sup_info{7} = spnum;%该图超像素个数

inds = cell(spnum,1);
[x, y] = meshgrid(1:1:n, 1:1:m);%m×n的矩阵，每行是1~n的数字

for i=1:spnum
    inds{i} = find(superpixels==i);% 超像素区域对应的像素点标号
    sup_info{1}(i,:) = mean(input_vals(inds{i},:),1);%每个超像素的平均颜色值 spnum×3
    sup_info{2}(i,:) = mean(depth(inds{i}));%每个超像素的平均深度值 spnum×1
    sup_info{3}(i,:) = mean(sin_sal(inds{i}));%每个超像素的平均单图显著性值 spnum×1
    sup_info{5}(i,:) = STATS(i).Area;
    sup_info{6}(i,:) = length(inds{i});%每个超像素包含像素的个数
    sup_info{4}(i,1) = sum(x(inds{i}))/sup_info{6}(i,:);%超像素的x坐标
    sup_info{4}(i,2) = sum(y(inds{i}))/sup_info{6}(i,:);%超像素的y坐标
end

end

