clc; clear all; close all;

%% image read and double precision
filename1 = '4.2.01.tiff';
RGB = imread(filename1);
RGB = im2double(RGB);

%% Grayscale
gray = im2gray(RGB);

%% 8x8 transformation matrix and dct
T = dctmtx(8);
dct = @(block_struct) T * block_struct.data * T';
B = blockproc(gray,[8 8],dct);

% discard all but 10 of 64 DCT coeff in each block
mask = [1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];

%% quantise dct with mask
B2 = blockproc(B,[8 8],@(block_struct) mask .* block_struct.data);

%% reconstruct imae using 2d inverse dct of each block
inv_dct = @(block_struct) T' * block_struct.data * T;
I2 = blockproc(B2,[8 8],inv_dct); % recon image I2

%% Difference, same types
Z = mat2gray(im2double(gray) - im2double(I2));

%% Write new images
imwrite (I2, 'Q5_gray.tiff');

%% Info 
info = imfinfo(filename1);
recon_in = imfinfo('Q5_gray.tiff');

%% Show images
figure, imshow(gray);
figure, imshow(I2);
figure, imshow(Z,[]);



