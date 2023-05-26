clc; clear all; close all;
filename1 = '4.2.01.tiff';

%% image read and double precision
RGB = imread(filename1);
RGB = im2double(RGB);

%% split RGB channels
YCbCr = rgb2ycbcr(RGB);
Y = YCbCr(:,:,1);
Cb = YCbCr(:,:,2);
Cr = YCbCr(:,:,3);

%% down-sampling, converts 512 to 256
Sub_Cb = Cb(1:2:end, 1:2:end); % gets all odd elements in x,y arr
Sub_Cr = Cr(1:2:end, 1:2:end); 

%% 8x8 transformation matrix
T = dctmtx(8);

%% 8x8 dct matrix
dct = @(block_struct) T * block_struct.data * T';
dct_Y = blockproc(Y,[8 8],dct);
dct_Cb = blockproc(Cb,[8 8],dct);
dct_Cr = blockproc(Cr,[8 8],dct);

%% discard all but 10 of 64 DCT coeff in each block
mask = [1   1   1   1   0   0   0   0
        1   1   1   0   0   0   0   0
        1   1   0   0   0   0   0   0
        1   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0
        0   0   0   0   0   0   0   0];

%% colors quantised
dct_Y = blockproc(dct_Y,[8 8],@(block_struct) mask .* block_struct.data);
dct_Cb = blockproc(dct_Cb,[8 8],@(block_struct) mask .* block_struct.data);
dct_Cr = blockproc(dct_Cr,[8 8],@(block_struct) mask .* block_struct.data);


%% reconstruct image using 2d inverse dct of each block
inv_dct = @(block_struct) T' * block_struct.data * T;
Y_I2 = blockproc(dct_Y,[8 8],inv_dct); 
Cb_I2 = blockproc(dct_Cb,[8 8],inv_dct); 
Cr_I2 = blockproc(dct_Cr,[8 8],inv_dct); 

%% color cat
recon_result = cat(3, Y_I2, Cb_I2, Cr_I2);
recon_result = ycbcr2rgb(recon_result);

%% Difference, same types
% Z = mat2gray(im2double(RGB)-im2double(recon_result));
Z = imabsdiff(RGB, recon_result);

%% Write new images
imwrite (recon_result, 'Q6.1_recon.tiff');

%% Info 
imfinfo('Q6.1_dct.tiff')

%% Show images
% figure, montage({RGB,recon_result})
figure, imshow(recon_result);
figure, imshow(Z,[]);
