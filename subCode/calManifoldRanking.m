function [ P ] = calManifoldRanking( sal_sim,adjc,spnum,alpha )
W = sal_sim.*adjc;% spnum��spnum��affinity����  ԭ�Ĺ�ʽ10
dd = sum(W,2); % �����ؽڵ�Ķ� degree
D = sparse(1:spnum,1:spnum,dd);% �ԽǾ���
P = (D-alpha*W)\eye(spnum); % eye������λ���� �ȼ���(D-alpha*W)����
end

