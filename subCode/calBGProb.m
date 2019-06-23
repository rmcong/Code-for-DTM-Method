function bgProb = calBGProb( seg_vals, superpixels, m, n )
%  RBD method of bgProb

bg_all = extract_bg_sp( superpixels, m, n );% extract the boundary of the iamge
colDistM = GetDistanceMatrix(seg_vals);
adjcMatrix = GetAdjMatrix(superpixels, max(max(superpixels)));
[clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);
[bgProb, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bg_all', clipVal, geoSigma);


end




