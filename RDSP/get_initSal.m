%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2018��6��9��
% �ú������� �������ͼ�Ŀɿ��Բ��ȷ�����Ȩ��
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




