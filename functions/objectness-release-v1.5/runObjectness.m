%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Objectness measure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Top-level routine implementation
% of the system described in the paper:
%
% B. Alexe, T. Deselaers, V. Ferrari
% What is an object?
% CVPR 2010
%
% The author and copyright holder is Bogdan Alexe.
% You might redistribute, reuse, and mofidy this code for
% research purposes. Any commercial application
% is forbidden without prior agreement in written
% by the author.

function boxes = runObjectness(img,numberSamples,params)
%This function computes the objectness measure and samples boxes from it.

dir_root = pwd;%change this to an absolute path

if nargin < 3
    try            
        struct = load('./functions/objectness-release-v1.5/Data/params.mat');
        params = struct.params;
        params.sampling ='multinomial';
        clear struct;
    catch
        params = defaultParams(dir_root);
        save('./functions/objectness-release-v1.5/Data/params.mat','params');
    end
end
%params = updatePath(dir_root,params);


if length(params.cues)==1    
    %single cues
    
    distributionBoxes = computeScores(img,params.cues{1},params); 
    
    switch lower(params.sampling)
        case 'nms'
            %nms sampling
            
            %consider only params.distribution_windows (= 100k windows)
            if size(distributionBoxes,1) > params.distribution_windows
                indexSamples = scoreSampling(distributionBoxes(:,5),params.distribution_windows,1);
                distributionBoxes = distributionBoxes(indexSamples,:);
            end
            
            %sampling
            boxes = nms_pascal(distributionBoxes, 0.5,numberSamples);
            
        case 'multinomial'            
            %multinomial sampling
            
            %sample from the distribution of the scores
            indexSamples = scoreSampling(distributionBoxes(:,end),numberSamples,1);
            boxes = distributionBoxes(indexSamples,:);
                        
        otherwise
            display('sampling procedure unknown')
    end

else
    %combination of cues
    
    if not(ismember('MS',params.cues)) 
        display('ERROR: combinations have to include MS');
        boxes = [];
        return
    end
    
    if length(unique(params.cues)) ~= length(params.cues)
        display('ERROR: repetead cues in the combination');
        boxes = [];
        return
    end
    
    distributionBoxes = computeScores(img,'MS',params);    
    %rearrange the cues such that 'MS' is the first cue
    if ~strcmp(params.cues{1},'MS')
        params.cues{strcmp(params.cues,'MS')} = params.cues{1};
        params.cues{1} ='MS';
    end
    
    score = zeros(size(distributionBoxes,1),length(params.cues));
    score(:,1) = distributionBoxes(:,end);
    windows = distributionBoxes(:,1:4);
    for idx = 2:length(params.cues)
        temp = computeScores(img,params.cues{idx},params,windows);
        score(:,idx) = temp(:,end);       
    end
    scoreBayes = integrateBayes(params.cues,score,params);      
    
    switch lower(params.sampling)
        case 'nms'
            %nms sampling
                        
            distributionBoxes(:,5) = scoreBayes;
            boxes = nms_pascal(distributionBoxes, 0.5, numberSamples);
            
        case 'multinomial'            
            %multinomial sampling
            
            %sample from the distribution of the scores
            indexSamples = scoreSampling(scoreBayes,numberSamples,1);  
        boxes = [windows(indexSamples,:) scoreBayes(indexSamples,:)];   
                        
        otherwise
            display('sampling procedure unknown')
    end            
    
end

    
