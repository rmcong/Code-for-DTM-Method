%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2018年6月9日
% 该函数用于 根据深度图的可靠性测度确定深度权重
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initSal = get_initSal( lammda,GCd,sal_sup,dep_vals )

if lammda >= 0.8
    initSal = 0.5*sal_sup+0.5*GCd;
elseif (lammda >= 0.3) && (lammda < 0.8)
    initSal = sal_sup.*dep_vals;
%     initSal = sal_sup.*exp(dep_vals);
else
    initSal = sal_sup;
end


end




