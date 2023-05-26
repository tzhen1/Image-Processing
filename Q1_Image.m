clc; close all; clear all;
% image
filename1 = '4.2.01.tiff';

% image read
RGB = imread(filename1); whos RGB
info = imfinfo(filename1)

% max and min values
min_intensity = min(RGB(:))
max_intensity = max(RGB(:))
%% Write new images
imwrite (Q1, 'Q2_dct.tiff');

% show image
imshow(RGB);