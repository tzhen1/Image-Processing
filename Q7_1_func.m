clc; close all; clear all;
filename1 = '4.2.01.tiff';
RGB = imread(filename1);
Original_Image = imread('4.2.01.tiff');
Quality_Factor= 100;

[Compressed_Data,Compressed_Image, recon_result] = JPEGcomp(Original_Image,Quality_Factor);

% Write new images
imwrite (Compressed_Image, 'Q7.3_recon.tiff');
imwrite (recon_result, 'Q7.4_recon.tiff');
% Info 
imfinfo('Q7.3_recon.tiff')
imfinfo('Q7.4_recon.tiff')

Z = (im2double(Original_Image)-im2double(Compressed_Image));

figure, montage({Original_Image,Compressed_Image});
figure, imshow(Z,[]);
figure, imshow(Z,[]);