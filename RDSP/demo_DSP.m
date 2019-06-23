clc;clear all;

addpath(genpath('.'));

spnumber = 200;
theta = 10;% ԭ����(1/sigma^2)=10,sigma^2=0.1
alpha = 0.99;

imgRoot = 'D:/1-CRM-CODE/CRM7-RGBD saliency/data/RGB797/';
depRoot = 'D:/1-CRM-CODE/CRM7-RGBD saliency/data/depth797/';
salRoot = 'D:/DataBase/RGBD saliency/STEREO797/RGB SALIENCY/16TIP-HDCT/';
outdir = 'D:/4-PaperResults/CRM7/RDSP/RDSP_797_HDCT/';
mkdir(outdir);
supdir = 'D:/1-CRM-CODE/CRM7-RGBD saliency/data/superpixels797_200/';


rgbFiles = dir(fullfile(imgRoot, '*.jpg'));%jpg��ʽ��RGBͼ�ļ���
depFiles = dir(fullfile(depRoot, '*.jpg'));%���ͼ�ļ���  ����������ͼΪpng��ʽ��ԭʼ���ͼΪjpg��ʽ
rgbFilesbmp = dir(fullfile(imgRoot, '*.bmp'));%bmp��ʽ��RGBͼ�ļ���

if isempty(rgbFilesbmp)
    sprintf('the input image format is ".bmp"');
    rgbFilesbmp = dir(fullfile(imgRoot, '*.jpg'));
    for i = 1:length(rgbFilesbmp)
        imgNamebmp = rgbFilesbmp(i).name;
        rgbbmp = imread(fullfile(imgRoot, imgNamebmp));
        savePath = fullfile(imgRoot, [imgNamebmp(1:end-4), '.bmp']);% imgName(1:end-4)��ʾ�õ�ͼƬ��ȥ��׺��.bmp֮�ࣩ������
        imwrite(rgbbmp,savePath,'bmp');        
    end %���rgb�ļ���ͼƬ��jpg��ʽ������ת����bmp��ʽ
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
    salnorm = normalize(sal);%��һ

    [m,n,k] = size(input_im);    
    input_vals=reshape(input_im, m*n, k);
    % load depth data
    if strfind( depName(1:strfind(depName,'.')-1), imgName(1:strfind(imgName,'.')-1) )
%         depth = double(importdata(fullfile(depthpath,depName)));% ����mat��ʽ���������
        depth = double(imread(fullfile(depRoot, depName)));% ����ͼƬ��ʽ���������
        depthnorm = normalize(depth);%��һ��
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
    STATS = regionprops(superpixels, 'all');%�õ������ر�ž�������������������������ġ������ȡ�
    adjc = calAdjacentMatrix(superpixels,spnum);
        
    % compute the feature (mean color in lab color space) for each superpixels    
    rgb_vals = zeros(spnum,3);
    dep_vals = zeros(spnum,1);
    inds=cell(spnum,1);
    [x, y] = meshgrid(1:1:n, 1:1:m);%m��n�ľ���ÿ����1~n������
    x_vals = zeros(spnum,1);
    y_vals = zeros(spnum,1);
    num_vals = zeros(spnum,1);
    Area_sup = zeros(spnum,1);
    sal_sup = zeros(spnum,1);
    for i=1:spnum
        inds{i}=find(superpixels==i);
        num_vals(i) = length(inds{i});%ÿ�������ذ������صĸ���
        rgb_vals(i,:) = mean(input_vals(inds{i},:),1);%ÿ�������ص�ƽ����ɫֵ spnum��3
        dep_vals(i,:) = mean(depthnorm(inds{i}));%ÿ�������ص�ƽ�����ֵ spnum��1
        x_vals(i) = sum(x(inds{i}))/num_vals(i);%�����ص�x����
        y_vals(i) = sum(y(inds{i}))/num_vals(i);%�����ص�y����
        Area_sup(i,:) = STATS(i).Area;
        sal_sup(i,:) = mean(salnorm(inds{i}));
    end  
    seg_vals = colorspace('Lab<-', rgb_vals);%ת����Lab�ռ� spnumn*3

    
    %% ��ȡ���ӳ��������ӵ�
    K1 = 30; % ������ѡ��ĳ�ʼ�����ӵ����
    ratio = 0.6; % ����������������ɸѡ��ĸ����ӵ����
    K2 = ceil(K1*ratio);
    [B1,sal_index] = sort(sal_sup,'descend');%��������ֵ���н�������
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
    seed_sal_all = sal_sup(seed_label_all).*center_prior;%������ ���ӵ������1
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
            neigh_label = Find_Neighbor( cen_label, adjc );% ������
            [seed_dep, neigh_dep, cen_dep] = Find_Depth( cen_label, neigh_label, dep_vals, seed_label );
            final_neigh_label = DEPTH_Panduan( cen_dep, neigh_dep, neigh_label, seed_dep, final_neigh_ori );
            [seed_dep_fin, neigh_dep_fin, cen_dep_fin] = Find_Depth( cen_label, final_neigh_label, dep_vals, seed_label );
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
    
    DSP = zeros(m,n);
    for k = 1:spnum
        DSP(inds{k}) = DSP_fusion(k);
    end

    MR_DSP = normalize((1-lammda)*salnorm + lammda*salnorm.*DSP);

    
    %% ���������ͼ
    mapstage1 = MR_DSP;
    mapstage1=uint8(mapstage1*255);
    savePath1 = fullfile(outdir, [imgName(1:end-4) '_HDCT_DSP.png']);
    imwrite(mapstage1,savePath1,'png');

    mapstage2 = DSP;
    mapstage2 = uint8(mapstage2*255);
    savePath2 = fullfile(outdir, [imgName(1:end-4) '_DSP.png']);
    imwrite(mapstage2,savePath2,'png');


end

toc;