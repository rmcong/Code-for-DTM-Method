function adjcMerge = calAdjacentMatrix(superpixels,spnum)
% $Description:
%    -compute the adjacent matrix
%    判断任意两个超像素间是否相邻，adjcMerge：spnum×spnum，即为判断超像素是否相
%    邻的矩阵，若adjloop（i，j）=1，表明第i和第j个超像素之间是相邻的。（注：spnum
%    表示超像素的个数）。
% $Agruments
% Input;
%    -M: superpixel label matrix
%    -N: superpixel number 
% Output:
%    -adjcMerge: adjacent matrix
%    adjcMerge：spnum×spnum，为判断超像素是否相邻的矩阵，若adjloop（i，j）=1，
%    表明第i和第j个超像素之间是相邻的

adjcMerge = zeros(spnum,spnum);
[m n] = size(superpixels);

for i = 1:m-1
    for j = 1:n-1
        if(superpixels(i,j)~=superpixels(i,j+1))
            adjcMerge(superpixels(i,j),superpixels(i,j+1)) = 1;
            adjcMerge(superpixels(i,j+1),superpixels(i,j)) = 1;
        end
        if(superpixels(i,j)~=superpixels(i+1,j))
            adjcMerge(superpixels(i,j),superpixels(i+1,j)) = 1;
            adjcMerge(superpixels(i+1,j),superpixels(i,j)) = 1;
        end
        if(superpixels(i,j)~=superpixels(i+1,j+1))
            adjcMerge(superpixels(i,j),superpixels(i+1,j+1)) = 1;
            adjcMerge(superpixels(i+1,j+1),superpixels(i,j)) = 1;
        end
        if(superpixels(i+1,j)~=superpixels(i,j+1))
            adjcMerge(superpixels(i+1,j),superpixels(i,j+1)) = 1;
            adjcMerge(superpixels(i,j+1),superpixels(i+1,j)) = 1;
        end
    end
end

%%{
% 所有边界相连
bd=unique([superpixels(1,:),superpixels(m,:),superpixels(:,1)',superpixels(:,n)']);
for i=1:length(bd)
    for j=i+1:length(bd)
        adjcMerge(bd(i),bd(j))=1;
        adjcMerge(bd(j),bd(i))=1;
    end
end
%}

%%{
% 二阶邻域
% adjc = adjcMerge;
% for i = 1:spnum
%     adjcMerge(i,:) = max([adjc(i,:);adjc(adjc(i,:)==1,:)],[],1);
% end
% adjcMerge = adjcMerge.*(1-eye(spnum));
% clear adjc