%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2018��6��9��
% �ú������� �������ͼ�Ŀɿ��Բ��ȷ�����Ȩ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function depW = get_depWeight( lammda )

if lammda >= 0.8
    depW = 1;
elseif (lammda >= 0.3) && (lammda < 0.8)
    depW = 0.5;
else
    depW = roundn(lammda,-1);
end


end



