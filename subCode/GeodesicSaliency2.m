function geoDist = GeodesicSaliency2(adjcMatrix, bdIds, colDistM)
% The core function for Geodesic Saliency Algorithm:
% Y.Wei, F.Wen,W. Zhu, and J. Sun. Geodesic saliency using background
% priors. In ECCV, 2012.

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

spNum = size(adjcMatrix, 1);
% Set background super-pixels
bgIds = bdIds;

% Calculate pair-wise geodesic distance
adjcMatrix_lb = LinkBoundarySPs(adjcMatrix, bdIds); %adjacent matrix with boundary SPs linked
[row,col] = find(adjcMatrix_lb);

% Here we add a virtual background node which is linked to all background
% super-pixels with 0-cost. To do this, we padding an extra row and column 
% to adjcMatrix_lb, and get adjcMatrix_virtual.
adjcMatrix_virtual = sparse([row; repmat(spNum + 1, [length(bgIds), 1]); bgIds], ...
    [col; bgIds; repmat(spNum + 1, [length(bgIds), 1])], 1, spNum + 1, spNum + 1);

% Specify edge weights for the new graph
colDistM_virtual = zeros(spNum+1);
colDistM_virtual(1:spNum, 1:spNum) = colDistM;

adjcMatrix_virtual = tril(adjcMatrix_virtual, -1);
edgeWeight = colDistM_virtual(adjcMatrix_virtual > 0);
% edgeWeight = max(0, edgeWeight - clip_value);
geoDist = graphshortestpath(sparse(adjcMatrix_virtual), spNum + 1, 'directed', false, 'Weights', edgeWeight);
geoDist = geoDist(1:end-1); % exclude the virtual background node

doRenorm = true;    %re-normalize saliency map, normalize saliency value of the top 2% pixels to 1
topRate = 0.02;
if doRenorm
    tmp = sort(geoDist, 'descend');
    pos = round(topRate * length(tmp));
    maxVal = tmp(pos);
    geoDist = geoDist / maxVal; %minVal = 0
    geoDist(geoDist > 1) = 1;
end
geoDist = geoDist';