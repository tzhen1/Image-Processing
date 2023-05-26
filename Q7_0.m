clc; close all; clear all;
filename1 = '4.2.01.tiff';
% different down sample method

% image read and double precision
RGB = imread(filename1);
RGB = im2double(RGB);

% image to  YCbCr component
YCbCr = rgb2ycbcr(RGB);
Y = YCbCr(:,:,1);
Cb = YCbCr(:,:,2);
Cr = YCbCr(:,:,3);

%down-sampling, converts 512 to 256
Sub_Cb = Cb(1:2:end, 1:2:end); % gets all odd elements in x,y arr
Sub_Cr = Cr(1:2:end, 1:2:end); 

% 8x8 transformation matrix
T = dctmtx(8);

% 8x8 dct matrix
dct = @(block_struct) T * block_struct.data * T';
% dct yuv
q_max = 255;
% dct_Y = blockproc(Y,[8 8],dct);
% dct_Cb = blockproc(Sub_Cb,[8 8],dct);
% dct_Cr = blockproc(Sub_Cr,[8 8],dct);

% quantisation table for luminance

q_y = [16 11 10 16 24 40 51 61;
       12 12 14 19 26 58 60 55;
       14 13 16 24 40 57 69 56;
       14 17 22 29 51 87 80 62;
       18 22 37 56 68 109 103 77;
       24 35 55 64 81 104 113 92;
       49 64 78 87 103 121 120 101;
       72 92 95 98 112 100 103 99];

% quantisation table for chrominance
q_c =  [17 18 24 47 99 99 99 99;
        18 21 26 66 99 99 99 99;
        24 26 56 99 99 99 99 99;
        47 66 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99];

% quantise dct coeff
dct_Y = blockproc(dct_Y,[8 8],@(block_struct) round(round(block_struct.data) ./ q_y));
dct_Cb = blockproc(dct_Y,[8 8],@(block_struct) round(round(block_struct.data) ./ q_c));
dct_Cr = blockproc(dct_Y,[8 8],@(block_struct) round(round(block_struct.data) ./ q_c));

% inverse dct
inv_dct = @(block_struct) T' * block_struct.data * T;
I_Y = blockproc(dct_Y,[8 8],inv_dct); % recon components
I_Cb = blockproc(dct_Cb,[8 8],inv_dct); 
I_Cr = blockproc(dct_Cr,[8 8],inv_dct); 

% concatenate channels
jpeg_result = ycbcr2rgb(cat(3, I_Y, I_Cb, I_Cr));
% jpeg_result = cat(3, Y, Cb, Cr);

% Difference, same types
Z = imabsdiff(RGB, jpeg_result); % double

% Write new images
imwrite (jpeg_result, 'Q7_jpeg.tiff');

% Info 
imfinfo('Q7_jpeg.tiff')

% Show images
figure, montage({RGB,jpeg_result})
figure, imshow(Z,[]);
