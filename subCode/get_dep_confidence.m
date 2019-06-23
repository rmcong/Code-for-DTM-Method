%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2016��6��1��
% �ú������� �������ͼ�Ŀɿ��Բ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lammda = get_dep_confidence( depth_norm )

%���ͼ�Ļ�������
aver = mean(mean(depth_norm));
square = sum(sum((depth_norm-aver).^2))/numel(depth_norm);%����
CV = sqrt(square)/aver;%����ϵ��
%��ȵ�Ƶ�ʷ���
P1 = numel(find(depth_norm<=0.4))/numel(depth_norm);
P2 = numel(find((depth_norm>0.4)&(depth_norm<=0.6)))/numel(depth_norm);
P3 = numel(find(depth_norm>0.6))/numel(depth_norm);
%��ֵ
H = -(P1*(LOG(P1)/log(3)))-(P2*(LOG(P2)/log(3)))-(P3*(LOG(P3)/log(3)));
%���ͼ�ɿ����
lammda = exp((1-aver)*CV*H)-1;
end




