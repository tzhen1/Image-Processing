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

%% down-sampling, converts 512 to 256 by smoothing filtering
% Eyes not sensitive to color can downsample by factor 2
h1 = [1 1; 1 1]/4;
Cb = imfilter (YCbCr(:,:,2), h1);
Cr = imfilter (YCbCr(:,:,3), h1);

% start pos 2, in jumps of 2, num rows and do same for col
Cb = Cb(2:2:size(Cb,1), 2:2:size(Cb,2));
Cr = Cr(2:2:size(Cr,1), 2:2:size(Cr,2));

%% partitioned into 8x8 transformation matrix
T = dctmtx(8);
dct = @(block_struct) T * block_struct.data * T';

q_max = 255;
dct_Y = blockproc(Y,[8 8],dct) .* q_max;
dct_Cb = blockproc(Cb,[8 8],dct) .* q_max;
dct_Cr = blockproc(Cr,[8 8],dct) .* q_max;

%% quantisation table for luminance, filter high freq
q_y = [16 11 10 16 24 40 51 61;
       12 12 14 19 26 58 60 55;
       14 13 16 24 40 57 69 56;
       14 17 22 29 51 87 80 62;
       18 22 37 56 68 109 103 77;
       24 35 55 64 81 104 113 92;
       49 64 78 87 103 121 120 101;
       72 92 95 98 112 100 103 99];

%% quantisation table for chrominance
q_c =  [17 18 24 47 99 99 99 99;
        18 21 26 66 99 99 99 99;
        24 26 56 99 99 99 99 99;
        47 66 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99;
        99 99 99 99 99 99 99 99];

%% quality factor change on freq
qf = 75; %75
if qf > 96
    q_scale = 1;
elseif qf < 50
    q_scale = floor(5000/qf);
else
    q_scale = 200 - 2 * qf;
end

q_y = round(q_y * (q_scale / 100));
q_c = round(q_c * (q_scale / 100));

%% quantise
dct_Y = blockproc(dct_Y,[8 8],@(block_struct) round(round(block_struct.data) ./ q_y));
dct_Cb = blockproc(dct_Cb,[8 8],@(block_struct) round(round(block_struct.data) ./ q_c));
dct_Cr = blockproc(dct_Cr,[8 8],@(block_struct) round(round(block_struct.data) ./ q_c));

%% dequantise
dct_Y = blockproc(dct_Y,[8 8],@(block_struct) q_y .* block_struct.data);
dct_Cb = blockproc(dct_Cb,[8 8],@(block_struct) q_c .* block_struct.data);
dct_Cr = blockproc(dct_Cr,[8 8],@(block_struct) q_c .* block_struct.data);

%% reconstruct image using 2d inverse dct of each block
inv_dct = @(block_struct) T' * block_struct.data * T;
Y_I2 = blockproc(dct_Y ./ q_max,[8 8],inv_dct); 
Cb_I2 = blockproc(dct_Cb ./ q_max,[8 8],inv_dct); 
Cr_I2 = blockproc(dct_Cr ./ q_max,[8 8],inv_dct); 

%% upsample filter
upsample_fil1 = [1 3 3 1]/4;
upsample_fil2 = upsample_fil1' * upsample_fil1;
% up sample using conv2 padararray () to fill array
Cb_I2 = conv2 (upsample_fil2, upsample(upsample(padarray(Cb_I2, [ 1 1 ], 'replicate'), 2)', 2)');
Cb_I2 = Cb_I2 (4:size(Cb_I2 , 1) - 4, 4:size(Cb_I2 , 2) - 4) ;
Cr_I2 = conv2 (upsample_fil2, upsample(upsample(padarray(Cr_I2, [ 1 1 ], 'replicate'), 2)', 2 )') ;
Cr_I2 = Cr_I2 (4:size(Cr_I2 , 1) - 4, 4:size(Cr_I2 , 2) - 4);

%% color cat
recon_result = cat(3, Y_I2, Cb_I2, Cr_I2);
recon_result = ycbcr2rgb(recon_result);

%% Difference, same types
Z = imabsdiff(RGB, recon_result);

%% Write new images
imwrite (recon_result, 'Q7.1_recon.tiff');

%% Info 
imfinfo('Q7.1_recon.tiff')

%% Show images
figure, imshow(recon_result);
figure, imshow(Z,[]);
