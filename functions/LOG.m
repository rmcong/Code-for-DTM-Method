function [ output ] = LOG( input )
% 重新定义以e为底的log函数，使输入等于0时，log0不等于NaN，而等于一个很小的
if input==0
    output=-10^10;
else
    output=log(input);
end

end

