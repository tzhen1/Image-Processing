clc; close all; clear all;

%% image read
filename1 = '4.2.01.tiff';
RGB = imread(filename1);

%% gray scale
gray = im2gray(RGB); 

%% 2D DCT + quantise
dct_I = dct2(gray);
dct_I(abs(dct_I) < 10) = 0;

%5 Inverse DCT and rescale
gray_recon = idct2(dct_I);
gray_recon = uint8(gray_recon);
% gray_recon = rescale(gray_recon);

%% Write new images
imwrite (dct_I, 'Q2_dct.tiff');
imwrite (gray, 'Q2_original_gray.tiff');
imwrite (gray_recon, 'Q2_gray_recon.tiff');

%% Info size
im_dct = dir('Q2_dct.tiff').bytes
gray1_size = dir('Q2_original_gray.tiff').bytes
gray2_size = dir('Q2_gray_recon.tiff').bytes
compress_ratio = gray1_size ./ im_dct % ori / recon

%% show images
figure, imshow(gray);
figure, imshow(gray_recon);

