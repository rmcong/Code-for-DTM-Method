function Diff = Simtexture( inputtexture )
% �ú������ڼ��㳬���ؼ�����������(���ò���ȶ��巽��)
% inputtextureΪ����ĳ����ؼ���LBP����������ΪspNum*59����
% Diff���Ϊ��ͬ�����ص���������
spNum = size(inputtexture, 1);
Diff = zeros(spNum, spNum);

for i = 1:spNum %�����ĳ�����
    tex=inputtexture(i,:)';%������������
    for j=1:spNum
        tex_other=inputtexture(j,:)';%������������
        Diff(i,j)=(abs(tex'*tex_other)./(norm(tex))./(norm(tex_other)));%��������       
    end
end
end

