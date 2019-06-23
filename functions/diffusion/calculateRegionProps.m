function regions = calculateRegionProps(sup_num,sulabel_im)

for r = 1:sup_num %% check the superpixel not along the image sides
	indxy = find(sulabel_im==r);
	[indx indy] = find(sulabel_im==r);
	regions{r}.pixelInd = indxy;
    regions{r}.pixelIndxy = [indx indy];
end