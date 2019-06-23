function FGSal = calFGSal(W_lab,W_dep,COMSal,dist,spnum,theta,num_vals,lammda,dep_vals,lbp_rate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2015/11/9 ��д  Diffusion-based Local Contrast

% W_lab��Lab��ɫ�ռ��euclid���� ��ʽ9 spnum��spnum
% COMSal����������������ͼ spnum��1
% dis��������֮��ľ��� spnum��spnum
% sal_lab��ԭ���й�ʽ11 �����ڵ�֮��������Ծ��� spnum��spnum
% spnum�������ظ�����adjc���ڽӾ���num_vals��ÿ�������ذ��������ظ�����x_vals,y_vals�������ص�x��y����
% lbp_rate��LBP��ȡ����������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ȷ��ǰ�����ӵ�
% % ����1�����������
FG_th = 0.5;
FG_label = find (COMSal >= FG_th);% ǰ�����ӵı��
dep_th = mean(dep_vals( FG_label ));
label = find ((COMSal >= FG_th) & (dep_vals >= dep_th));
FG_num = numel(label);
% % ����2�������������
% FG_th = 0.5;
% label = find (COMSal >= FG_th);% ǰ�����ӵı��
% FG_num = numel(label);
%% ����ǰ��������
% ɫ��������
col_sim = exp( -theta * normalize( W_lab ) );% �����ڵ�֮�����ɫ�����Ծ���  spnum��spnum ���Խ���Ԫ��Ϊ1
% ���������
dep_sim = exp( -theta * normalize( lammda * W_dep ) );% �����ڵ�֮�����������Ծ���  spnum��spnum ���Խ���Ԫ��Ϊ1
% ����������
tex_sim = Simtexture( lbp_rate );% �����ڵ�֮������������Ծ���  spnum��spnum ���Խ���Ԫ��Ϊ1
% ����Լ��
distance = exp( -theta * normalize( dist ) );% �����ڵ�֮�����ɫ�����Ծ���  spnum��spnum ���Խ���Ԫ��Ϊ1
D_FG = zeros(spnum,1);
for j = 1:spnum
    DD = 0;%��ʼ��ȶԱȶ�
    for ii = 1:FG_num
        jj = label(ii,1);% ���ӳ����ر��
        size_seed = num_vals(jj);%���ӳ����صĴ�С
        pos_seed = distance(j,jj);
        dep_seed = dep_sim(j,jj);
        color_seed = col_sim(j,jj);
        tex_seed = tex_sim(j,jj);
        DD = DD + (dep_seed * color_seed * tex_seed) * size_seed * pos_seed;
    end
    D_FG(j,1)=DD;
end
FGSal = normalize( D_FG );
end


