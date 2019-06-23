%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is for the paper: 
% Runmin Cong, Jianjun Lei, Huazhu Fu, Junhui Hou, Qingming Huang, and Sam Kwong, 
% Going from RGB to RGBD saliency: A depth-guided transformation model,
% IEEE Transactions on Cybernetics, 2019.

% It can only be used for non-comercial purpose. If you use our code, please cite our paper.

% For any questions, please contact rmcong@126.com  runmincong@gmail.com.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
clc;
addpath(genpath('.'));
addpath(genpath('./piotr_toolbox/'));%piotr toolbox

%%------------------------set parameters---------------------%%
spnumber = 200;
theta = 10;% (1/sigma^2)=10,sigma^2=0.1
alpha = 0.99;
suffix = '_RBD.png';

imgRoot = './data/RGB/';
depRoot = './data/depth/';
RGBSalRoot = './data/RBD/';

saldir = './results/DTM/';
supdir = './results/superpixels_200/';
mkdir(supdir);
mkdir(saldir);

rgbFilesbmp = dir(fullfile(imgRoot, '*.bmp'));
rgbFiles = dir(fullfile(imgRoot, '*.jpg'));
depFiles = dir(fullfile(depRoot, '*.jpg'));
if isempty(rgbFilesbmp)
    sprintf('the input image format is ".bmp"');
    rgbFilesbmp = dir(fullfile(imgRoot, '*.jpg'));
    for i = 1:length(rgbFilesbmp)
        imgNamebmp = rgbFilesbmp(i).name;
        rgbbmp = imread(fullfile(imgRoot, imgNamebmp));
        savePath = fullfile(imgRoot, [imgNamebmp(1:end-4), '.bmp']);
        imwrite(rgbbmp,savePath,'bmp');
    end 
    rgbFilesbmp = dir(fullfile(imgRoot, '*.bmp'));
end
if length(rgbFiles) ~= length(depFiles)
    error('the number of files is mismatching');
end


for ii=1:length(rgbFiles)
    disp(ii);
    % load RGB data
    imgName = rgbFiles(ii).name;
    imgNamebmp = rgbFilesbmp(ii).name;
    imgPathbmp = [imgRoot, imgNamebmp];
    input_im = double(imread(fullfile(imgRoot, imgName)));
    input_im(:,:,1) = normalize(input_im(:,:,1));
    input_im(:,:,2) = normalize(input_im(:,:,2));
    input_im(:,:,3) = normalize(input_im(:,:,3));
    [m,n,k] = size(input_im);
    input_vals = reshape(input_im, m*n, k);
    
    % load depth data
    depName = depFiles(ii).name;
    if strfind( depName(1:strfind(depName,'.')-1), imgName(1:strfind(imgName,'.')-1) )
        depth = double(imread(fullfile(depRoot, depName)));
        depthnorm = normalize(depth);
    else
        error('depth map name is mismatching.');
    end
    
    % load RGB saliency data
    salName = [imgName(1:end-4) suffix];
    RGBsal = double(imread(fullfile(RGBSalRoot, salName)));
    RGBsalnorm = normalize(RGBsal);
    
    
    %% SLIC
    if exist([supdir imgNamebmp(1:end - 4)  '.dat'],'file')
        disp('Skipping SLIC...');
        spname = [supdir imgNamebmp(1:end - 4)  '.dat'];
        superpixels = ReadDAT([m,n],spname);
    else
        disp('Performing SLIC...');
        comm = ['SLICSuperpixelSegmentation' ' ' imgPathbmp ' ' int2str(20) ' ' int2str(spnumber) ' ' supdir];
        system(comm);
        spname = [supdir imgNamebmp(1:end - 4)  '.dat'];
        superpixels = ReadDAT([m,n],spname);
    end
    
    [ sup_info, adjc, inds] = get_sup_info( superpixels, input_vals, depthnorm, RGBsalnorm, m, n );
    spnum = sup_info{7};
    regions = calculateRegionProps(spnum,superpixels);
    % depth confidence measure
    lammda = get_dep_confidence( depthnorm );
    
    %% Graph Construction and Manifold Ranking    
    dep_vals = sup_info{2};
    rgb_vals = sup_info{1};
    seg_vals = colorspace('Lab<-', rgb_vals);% spnumn*3
    dep_matrix1 = ones(spnum,1) * dep_vals';
    dep_matrix2 = dep_matrix1';
    Dlab =  DistanceZL(seg_vals, seg_vals, 'euclid');
    Ddep =  abs(dep_matrix2 - dep_matrix1);
    Argbd = exp( -theta * normalize( Dlab + lammda * Ddep ) );%spnum¡Áspnum 
    Argb = exp( -theta * normalize( Dlab ) );%spnum¡Áspnum 
    Adep = exp( -theta * normalize( lammda * Ddep ) );%spnum¡Áspnum 
    
    Prgbd = calManifoldRanking( Argbd,adjc,spnum,alpha );
    Prgb = calManifoldRanking( Argb,adjc,spnum,alpha );
    Pdep = calManifoldRanking( Adep,adjc,spnum,alpha );
    
    %% Multi-Level RGBD Saliency Detection (MLDS)
    % Global saliency via RGBD compactness
    PArgb = (Prgb*Argb)';
    PAdep = (Pdep*Adep)';
    num_vals = sup_info{6};

    PNArgb = PArgb.*(ones(spnum,1)*num_vals');
    PNAdep = PAdep.*(ones(spnum,1)*num_vals');

    Sumrgb = sum(PNArgb,2);
    Sumdep = sum(PNAdep,2);
    
    x_vals = sup_info{4}(:,1);
    y_vals = sup_info{4}(:,2);
    comSal_sup = calCompactness(PNArgb,PNAdep,Sumrgb,Sumdep,x_vals,y_vals,m,n,spnum);
%     CSal = Sup2Sal(comSal_sup,regions,m,n,spnum);%M*N % double M*N 0-1
%     saveimg( m,n,CSal,saldir,[imgName(1:end-4) '_CS.png'] )
    
    % Local saliency via geodesic distance
    bg_all = extract_bg_sp( superpixels, m, n );% extract the boundary of the iamge
    colDistM = GetDistanceMatrix(seg_vals);
    adjcMatrix = GetAdjMatrix(superpixels, max(max(superpixels)));
    [clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);
    [wCtr, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bg_all', clipVal, geoSigma);
    Pbg = wCtr.*exp( -theta * ( sup_info{3} + lammda * sup_info{2} ));
    [~,ind] = sort(Pbg,'descend');
    bg_num = ceil(0.2*spnum);
    BGindex = ind(1:bg_num);    
    BGall = unique(union(bg_all,BGindex));

    Drgbd = exp( theta * normalize( Dlab + lammda * Ddep ) );
    geoDist = GeodesicSaliency2(adjcMatrix, BGall, Prgbd);
%     GSal = Sup2Sal(geoDist,regions,m,n,spnum);%M*N % double M*N 0-1
%     saveimg( m,n,GSal,saldir,[imgName(1:end-4) '_GS.png'] )
    
    SML_sup = normalize(comSal_sup+(geoDist.*comSal_sup));
    SMLLP_sup = LabelPropagation( Argbd, adjc, SML_sup, spnum );
%     SMLLP = Sup2Sal(SMLLP_sup,regions,m,n,spnum);%M*N % double M*N 0-1
%     saveimg( m,n,SMLLP,saldir,[imgName(1:end-4) '_MLS.png'] ) 
     
    stage1_sup = 0.5*sup_info{3}; + 0.5*SMLLP_sup;
%     stage1 = Sup2Sal(stage1_sup,regions,m,n,spnum);%M*N % double M*N 0-1
%     saveimg( m,n,stage1,saldir,[imgName(1:end-4) '_stage1.png'] ) 

    %% Depth-Guided Saliency Refinement (DGSR)

    [ initSal, rdsp_fusion, RDSP_fusion ] = RDSP( sup_info, m, n, adjc, seg_vals, SMLLP_sup, lammda );
    sal_rdsp = normalize(initSal + rdsp_fusion);
    
%     MLSd = Sup2Sal(initSal,regions,m,n,spnum);%M*N % double M*N 0-1
%     saveimg( m,n,MLSd,saldir,[imgName(1:end-4) '_dok.png'] ) 
%     DRS = Sup2Sal(sal_rdsp,regions,m,n,spnum);%M*N % double M*N 0-1
%     saveimg( m,n,DRS,saldir,[imgName(1:end-4) '_DRS.png'] ) 

    %% Saliency Optimization with Depth Constraints (SODC)
    W1 = Argb.*adjc;
    d1 = sum(W1,2);%spnum*1
    D1 = sparse(1:spnum,1:spnum,d1);% spnum*spnum
    INN = sparse(1:spnum,1:spnum,ones(spnum,1)); % spnum*spnum
    W2 = Adep.*adjc;
    d2 = sum(W2,2);%spnum*1
    D2 = sparse(1:spnum,1:spnum,d2);% spnum*spnum
    Sf = (INN + (D1-W1) + (D2-W2))\( sal_rdsp );
    
    STM = Sup2Sal(Sf,regions,m,n,spnum);%M*N % double M*N 0-1
    saveimg( m,n,STM,saldir,[imgName(1:end-4) suffix(1:end-4) '_DTM.png'] ) 

end
