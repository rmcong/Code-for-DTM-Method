function input_im = readimage(imname)

% threshold=0.6;
input_im = imread(imname);
input_im = im2double(input_im);
% gray=rgb2gray(input_im);

outname=[imname(1:end-4) '.bmp'];
imwrite(input_im,outname);