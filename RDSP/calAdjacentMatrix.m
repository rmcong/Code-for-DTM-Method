function adjcMerge = calAdjacentMatrix(superpixels,spnum)
% $Description:
%    -compute the adjacent matrix
%    �ж��������������ؼ��Ƿ����ڣ�adjcMerge��spnum��spnum����Ϊ�жϳ������Ƿ���
%    �ڵľ�����adjloop��i��j��=1��������i�͵�j��������֮�������ڵġ���ע��spnum
%    ��ʾ�����صĸ�������
% $Agruments
% Input;
%    -M: superpixel label matrix
%    -N: superpixel number 
% Output:
%    -adjcMerge: adjacent matrix
%    adjcMerge��spnum��spnum��Ϊ�жϳ������Ƿ����ڵľ�����adjloop��i��j��=1��
%    ������i�͵�j��������֮�������ڵ�

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
% ���б߽�����
bd=unique([superpixels(1,:),superpixels(m,:),superpixels(:,1)',superpixels(:,n)']);
for i=1:length(bd)
    for j=i+1:length(bd)
        adjcMerge(bd(i),bd(j))=1;
        adjcMerge(bd(j),bd(i))=1;
    end
end
%}

%%{
% ��������
% adjc = adjcMerge;
% for i = 1:spnum
%     adjcMerge(i,:) = max([adjc(i,:);adjc(adjc(i,:)==1,:)],[],1);
% end
% adjcMerge = adjcMerge.*(1-eye(spnum));
% clear adjc