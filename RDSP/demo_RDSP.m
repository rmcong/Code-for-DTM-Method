%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Refined Depth Shape Prior
%%% 2018-06-11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clc;
clear all;

addpath(genpath('.'));

spnumber = 200;
theta = 10;% 原文中(1/sigma^2)=10,sigma^2=0.1
alpha = 0.99;

imgRoot = 'D:/1-CRM-CODE/CRM7-RGBD saliency/data/RGB797/';
depRoot = 'D:/1-CRM-CODE/CRM7-RGBD saliency/data/depth797/';
salRoot = 'D:/DataBase/RGBD saliency/STEREO797/RGB SALIENCY/16TIP-HDCT/';
outdir = 'D:/4-PaperResults/CRM7/RDSP/RDSP_797_HDCT/';
mkdir(outdir);
supdir = 'D:/1-CRM-CODE/CRM7-RGBD saliency/data/superpixels797_200/';

rgbFiles = dir(fullfile(imgRoot, '*.jpg'));%jpg格式的RGB图文件夹
depFiles = dir(fullfile(depRoot, '*.jpg'));%深度图文件夹  修正后的深度图为png格式，原始深度图为jpg格式
rgbFilesbmp = dir(fullfile(imgRoot, '*.bmp'));%bmp格式的RGB图文件夹

if isempty(rgbFilesbmp)
    sprintf('the input image format is ".bmp"');
    rgbFilesbmp = dir(fullfile(imgRoot, '*.jpg'));
    for i = 1:length(rgbFilesbmp)
        imgNamebmp = rgbFilesbmp(i).name;
        rgbbmp = imread(fullfile(imgRoot, imgNamebmp));
        savePath = fullfile(imgRoot, [imgNamebmp(1:end-4), '.bmp']);% imgName(1:end-4)表示得到图片除去后缀（.bmp之类）的名字
        imwrite(rgbbmp,savePath,'bmp');        
    end %如果rgb文加下图片是jpg格式，将其转换成bmp格式
    rgbFilesbmp = dir(fullfile(imgRoot, '*.bmp'));
end
if length(rgbFiles) ~= length(depFiles)
    error('the number of files is mismatching');
end
tic
for ii = 1:length(rgbFiles)   
    disp(ii);
    
    depName = depFiles(ii).name;
    imgName = rgbFiles(ii).name;
    salName = [imgName(1:end-4),'_HDCT.png'];% load single saliency map
    
    imgNamebmp = rgbFilesbmp(ii).name;
    imgPathbmp = [imgRoot, imgNamebmp];
    
    input_im = double(imread(fullfile(imgRoot, imgName)));
    input_im(:,:,1)=normalize(input_im(:,:,1));
    input_im(:,:,2)=normalize(input_im(:,:,2));
    input_im(:,:,3)=normalize(input_im(:,:,3));
    
    sal = double(imread(fullfile(salRoot, salName)));   
    salnorm = normalize(sal);%归一

    [m,n,k] = size(input_im);    
    input_vals=reshape(input_im, m*n, k);
    % load depth data
    if strfind( depName(1:strfind(depName,'.')-1), imgName(1:strfind(imgName,'.')-1) )
%         depth = double(importdata(fullfile(depthpath,depName)));% 读入mat格式的深度数据
        depth = double(imread(fullfile(depRoot, depName)));% 读入图片格式的深度数据
        depthnorm = normalize(depth);%归一化
    else
        error('depth image name is mismatching.');
    end
    lammda = get_dep_confidence( depthnorm );

%% SLIC
    comm = ['SLICSuperpixelSegmentation' ' ' imgPathbmp ' ' int2str(20) ' ' int2str(spnumber) ' ' supdir];
    system(comm);    
    spname = [supdir imgNamebmp(1:end - 4)  '.dat'];
    superpixels = ReadDAT([m,n],spname);
    spnum = max(superpixels(:));
    STATS = regionprops(superpixels, 'all');%得到超像素标号矩阵的所有属性特征，包括质心、个数等。
    adjc = calAdjacentMatrix(superpixels,spnum);
        
    % compute the feature (mean color in lab color space) for each superpixels    
    rgb_vals = zeros(spnum,3);
    dep_vals = zeros(spnum,1);
    inds=cell(spnum,1);
    [x, y] = meshgrid(1:1:n, 1:1:m);%m×n的矩阵，每行是1~n的数字
    x_vals = zeros(spnum,1);
    y_vals = zeros(spnum,1);
    num_vals = zeros(spnum,1);
    Area_sup = zeros(spnum,1);
    sal_sup = zeros(spnum,1);
    for i=1:spnum
        inds{i}=find(superpixels==i);
        num_vals(i) = length(inds{i});%每个超像素包含像素的个数
        rgb_vals(i,:) = mean(input_vals(inds{i},:),1);%每个超像素的平均颜色值 spnum×3
        dep_vals(i,:) = mean(depthnorm(inds{i}));%每个超像素的平均深度值 spnum×1
        x_vals(i) = sum(x(inds{i}))/num_vals(i);%超像素的x坐标
        y_vals(i) = sum(y(inds{i}))/num_vals(i);%超像素的y坐标
        Area_sup(i,:) = STATS(i).Area;
        sal_sup(i,:) = mean(salnorm(inds{i}));
    end  
    seg_vals = colorspace('Lab<-', rgb_vals);%转换到Lab空间 spnumn*3
    
        
    %% 计算深度全局对比
    dep_matrix1 = ones(spnum,1) * dep_vals';
    dep_matrix2 = dep_matrix1';
    dist = sqrt((x_vals*ones(1,spnum) - ones(spnum,1)*x_vals').^2 + (y_vals*ones(1,spnum) - ones(spnum,1)*y_vals').^2);
    GCd =  normalize(sum(abs(dep_matrix2 - dep_matrix1).*exp(-10*dist),2));
%     depW = get_depWeight(lammda); 
    
    %% 获取种子超像素种子点
    K1 = 30; % 显著性选择的初始根种子点个数
    ratio = 0.6; % 最终利用中心先验筛选后的根种子点比例
    
    % 选择显著性值大的超像素作为初始根种子点
    initSal = get_initSal( lammda,GCd,sal_sup,dep_vals );
    initSal = normalize(initSal);
    [B1,sal_index1] = sort(initSal,'descend');%对显著性值进行降序排列
    sal_label1 = sal_index1(1:K1);%前K1个较大的显著性值对应的超像素标号
   
    % 利用中心先验进一步筛选  确定最终的根种子点   
    sp_x1 = x_vals(sal_label1);
    sp_y1 = y_vals(sal_label1); 
    x_cen = ones(K1,1).*n.*0.5;
    y_cen = ones(K1,1).*m.*0.5;
    K2 = ceil(K1*ratio);
    sp_dis = sqrt((sp_x1 - x_cen).^2 + (sp_y1 - y_cen).^2);
    [B2,sp_index] = sort(sp_dis,'ascend');%对空间位置进行升序排列
    sal_label2 = sal_label1(sp_index(1:K2));%在显著性超像素标号中选择前K2个距离图片中心较近的超像素标号
    th = mean(initSal(sal_label1));
    seed_label_all = sal_label2(find(initSal(sal_label2)>=th));
    seed_num = length(seed_label_all);
    
    %% 扩散搜索过程

    RDSP_label = zeros(spnum,seed_num);
    RDSP_value = zeros(spnum,seed_num);
    for jj = 1:seed_num
        indictor = 1;
        k = 2;
        seed_label = seed_label_all(jj);%种子超像素节点       
        cen_label = seed_label;%初始化中心超像素节点
        
        DS_label = zeros(spnum,1);%此种子超像素节点的deph shape label
        DS_value = zeros(spnum,1);%此种子超像素节点的deph shape value
        DS_label(cen_label) = 1;%种子超像素节点的deph shape mask置1
        DS_value(cen_label) = 1;%种子超像素节点的deph shape mask置1
        
        final_neigh_ori = [];
        while (indictor == 1)
            neigh_label = Find_Neighbor( cen_label, adjc );% 列向量
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
%         DS(find(DS~=0)) = 1;%将所有找到的满足条件的邻域超像素对应位置置1
        RDSP_label(:,jj) = DS_label;
        RDSP_value(:,jj) = DS_value;
    end
    %% 基于DSP的显著性值计算（多个DSP融合）
    rdsp_fusion = RDSP_value*initSal(seed_label_all)./seed_num;
    RDSP_fusion = normalize(rdsp_fusion);
    
%     DSP_fusion = normalize(mean(RDSP_value,2));

%     sal_rdsp = normalize(initSal.*rdsp_fusion);
%     sal_rdsp = normalize(initSal + initSal.*rdsp_fusion);
    sal_rdsp = normalize(initSal + rdsp_fusion);
    
    RDSP = zeros(m,n);
    ISAL = zeros(m,n);
    sal_RDSP = zeros(m,n);
    for k = 1:spnum
        RDSP(inds{k}) = RDSP_fusion(k);
        ISAL(inds{k}) = initSal(k);
        sal_RDSP(inds{k}) = sal_rdsp(k);
    end

    
    %% 输出显著性图
    mapstage1 = sal_RDSP;
    mapstage1=uint8(mapstage1*255);
    savePath1 = fullfile(outdir, [imgName(1:end-4) '_HDCT_RDSP.png']);
    imwrite(mapstage1,savePath1,'png');

    mapstage2 = RDSP;
    mapstage2 = uint8(mapstage2*255);
    savePath2 = fullfile(outdir, [imgName(1:end-4) '_RDSP.png']);
    imwrite(mapstage2,savePath2,'png');
    
%     mapstage3 = ISAL;
%     mapstage3 = uint8(mapstage3*255);
%     savePath2 = fullfile(outdir, [imgName(1:end-4) '_init.png']);
%     imwrite(mapstage3,savePath2,'png');


end

toc;