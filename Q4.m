clc; close all; clear all;

%% image read
filename1 = '4.2.01.tiff';
RGB = imread(filename1);

%% Grayscale
gray = im2gray(RGB);

%% 2D DCT, uniform quantise
[cA,cH,cV,cD] = dwt2(RGB,'db1');
sX=size(RGB);

figure(1)
subplot(2,2,1);imshow(uint8(cA));title('cA');
subplot(2,2,2);imshow(uint8(cH));title('cH');
subplot(2,2,3);imshow(uint8(cV));title('cV');
subplot(2,2,4);imshow(uint8(cD));title('cD');

%% Inverse dct and scale
recon = idwt2(cA,cH,cV,cD,'db1',sX);

%% Difference, same types
% Z = imabsdiff(gray, gray_recon_uint8) % uint8
% Z = imabsdiff(gray, gray_recon);
Z = im2double(RGB)-im2double(recon);

%% Write new images
imwrite (uint8(recon), 'Q4_diff.tiff');

%% Info 
bytes_recon = dir('Q4_diff.tiff').bytes
gray1_size = dir('4.2.01.tiff').bytes
compress_ratio = gray1_size ./ bytes_recon % ori / recon


%% Show images
% figure, montage({gray,gray_recon});
figure, imshow(uint8(recon));
% figure, imshow(Z, []);