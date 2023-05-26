clc; close all; clear all;

%% image read
filename1 = '4.2.01.tiff';
RGB = imread(filename1);

%% Grayscale
gray = im2gray(RGB);

%% 2D DCT, uniform quantise
dct_I = dct2(gray);
dct_I(abs(dct_I) < 10) = 0;

%% Inverse dct and scale
gray_recon = idct2(dct_I);
gray_recon = rescale(gray_recon); 

%% Difference, same types

Z = mat2gray(im2double(gray)-im2double(gray_recon));

%% Write new images
imwrite (dct_I, 'Q3_diff.tiff');

%% Info 
im_diff = dir('Q3_diff.tiff').bytes

%% Show images
figure, montage({gray,gray_recon});
figure, imshow(Z, []);