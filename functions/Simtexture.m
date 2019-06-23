function Diff = Simtexture( inputtexture )
% 该函数用于计算超像素级的纹理差异度(利用差异度定义方法)
% inputtexture为输入的超像素级的LBP纹理特征，为spNum*59矩阵
% Diff输出为不同超像素的纹理差异度
spNum = size(inputtexture, 1);
Diff = zeros(spNum, spNum);

for i = 1:spNum %待求解的超像素
    tex=inputtexture(i,:)';%纹理特征向量
    for j=1:spNum
        tex_other=inputtexture(j,:)';%纹理特征向量
        Diff(i,j)=(abs(tex'*tex_other)./(norm(tex))./(norm(tex_other)));%纹理差异度       
    end
end
end

