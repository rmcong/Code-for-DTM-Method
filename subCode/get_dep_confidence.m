%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2016年6月1日
% 该函数用于 计算深度图的可靠性测度
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lammda = get_dep_confidence( depth_norm )

%深度图的基本特征
aver = mean(mean(depth_norm));
square = sum(sum((depth_norm-aver).^2))/numel(depth_norm);%方差
CV = sqrt(square)/aver;%变异系数
%深度的频率分析
P1 = numel(find(depth_norm<=0.4))/numel(depth_norm);
P2 = numel(find((depth_norm>0.4)&(depth_norm<=0.6)))/numel(depth_norm);
P3 = numel(find(depth_norm>0.6))/numel(depth_norm);
%熵值
H = -(P1*(LOG(P1)/log(3)))-(P2*(LOG(P2)/log(3)))-(P3*(LOG(P3)/log(3)));
%深度图可靠测度
lammda = exp((1-aver)*CV*H)-1;
end




