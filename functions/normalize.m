function value = normalize(in)
% ����ֵ��Χ��һ����0~1

value = (in - min(in(:)))/(max(in(:)) - min(in(:)));