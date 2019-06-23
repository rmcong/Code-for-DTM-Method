function Kernel = DistanceZL(FeaVector_1, FeaVector_2, ker)
% 计算用于SVM分类的核
% Input：
%           FeaVector_1：个数 × 维数
%           FeaVector_1：个数 × 维数
%           ker        ：使用的核函数
%                           'linear'
%                           'polynomial'
%                           'rbf' 
%                           'sigmoid'
%                           'bhattacharyya'
% Output：
%           Kernel：size(FeaVector_1,1) × size(FeaVector_2,1)

if size(FeaVector_1,2) ~= size(FeaVector_2,2)
	error('Data dimension does not match dimension of centres')
end
if nargin < 3
    ker = 'bhattacharyya';
end

num_1 = size(FeaVector_1,1);
num_2 = size(FeaVector_2,1);
Kernel = zeros(num_1,num_2);

switch lower(ker)
    case 'linear'
        Kernel = FeaVector_1*FeaVector_2';
    case 'polynomial'
        p1=2;
        b=1;
        Kernel = (FeaVector_1*FeaVector_2' + b).^p1;
    case 'rbf' 
        n2 = (ones(num_2, 1) * sum((FeaVector_1.^2)', 1))' + ...
          ones(num_1, 1) * sum((FeaVector_2.^2)',1) - ...
          2.*(FeaVector_1*(FeaVector_2'));
        Kernel = n2;
    case 'sigmoid'
        Kernel = tanh(FeaVector_1*FeaVector_2');
    case 'bhattacharyya'
        n2 = sqrt( 1-sqrt(FeaVector_1)*sqrt(FeaVector_2') );
        Kernel = n2;
    case 'chi'
        n2 = zeros(num_1,num_2);
        for i = 1:num_2
            n1 = ones(num_1,1)*FeaVector_2(i,:);
            n2(:,i) = sum((FeaVector_1-n1).^2./(0.0000001+abs(FeaVector_1)+abs(n1)),2)/2;
        end        
        Kernel = n2;
    case 'euclid'
        n2 = zeros(num_1,num_2);
        for i = 1:num_2
            n1 = ones(num_1,1)*FeaVector_2(i,:);
            n2(:,i) = sum((FeaVector_1 - n1).^2,2);
        end        
        Kernel = sqrt(n2);
    case 'isect'
        Kernel = hist_isect(FeaVector_1, FeaVector_2);        
    otherwise
        Kernel = FeaVector_1*FeaVector_2';
end

function K = hist_isect(x1, x2)
% Evaluate a histogram intersection kernel, for example
%
%    K = hist_isect(x1, x2);
%
% where x1 and x2 are matrices containing input vectors, where 
% each row represents a single vector.
% If x1 is a matrix of size m x o and x2 is of size n x o,
% the output K is a matrix of size m x n.

n = size(x2,1);
m = size(x1,1);
K = zeros(m,n);

if (m <= n)
   for p = 1:m
       nonzero_ind = find(x1(p,:)>0);
       tmp_x1 = repmat(x1(p,nonzero_ind), [n 1]); 
       K(p,:) = sum(min(tmp_x1,x2(:,nonzero_ind)),2)';
   end
else
   for p = 1:n
       nonzero_ind = find(x2(p,:)>0);
       tmp_x2 = repmat(x2(p,nonzero_ind), [m 1]);
       K(:,p) = sum(min(x1(:,nonzero_ind),tmp_x2),2);
   end
end