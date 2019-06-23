function saveimg( m,n,interSal,cosal_path,savename )
interSal_new = imresize(interSal,[m,n]);
mapstage1 = interSal_new;
mapstage1 = uint8(mapstage1*255);
savePath = fullfile(cosal_path, savename);
imwrite(mapstage1,savePath,'png');

end

