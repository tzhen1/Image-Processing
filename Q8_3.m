clc; close all; clear all;

%% image read
filename1 = '4.2.01.tiff';
RGB = imread(filename1);

% RGB_8x8 = RGB(81:88,81:88);
% [x,y] = size(RGB);
% y = x;
% x = x/8;
% y = y/8;
%% Grayscale
gray = im2gray(RGB);

%% 2D DCT, uniform quantise
% dct_I = dct2(gray);

% function C=fun_dct(X)


% for i=2:y
%     for j=1:y
%         dct_I(i,j)=sqrt(2/y)*cos((i-1)*(j-1/2)*pi/y);
%     end
% end
% dct_I(1,1:y)=ones(1,y)/sqrt(y);

%    function image_comp = DCTlocal( I )
   N=8;
   [x,y]=size(RGB);
    RGB=double(RGB)-128;
    block_dct = zeros(N);

    %loop true block
     for k=1:N:x
     for l=1:N:y
      %save true image
      current_block = RGB(k:k+N-1,l:l+N-1);
      %loop true cos(u,v)
       for u=0:N-1
        for v=0:N-1
          if u==0
            Cu = 1/sqrt(2);
          else
            Cu = 1;
          end
        if v==0
            Cv = 1/sqrt(2);
        else
            Cv = 1;
        end
        Res_sum = 0; %loop true pixel values
         for x=0:N-1
          for y=0:N-1
            Res_sum = Res_sum +((current_block(x+1,y+1))*cos(((2*x)+1)*u*pi/(2*N))*cos(((2*y)+1)*v*pi/(2*N)));  
          end
         end
         dct = 1/sqrt(2*N) * Cu * Cv * Res_sum; %calculate DCT
        block_dct(u+1,v+1) = dct;
      end
     end
        image_comp(k:k+N-1,l:l+N-1) = block_dct(u+1,v+1);
    end
     end


%% Inverse dct and scale
% gray_recon = idct2(dct_I);
% gray_recon = rescale(gray_recon); 
% gray_recon_uint8 = uint8(gray_recon);

%% Difference, same types
% Z = imabsdiff(gray, gray_recon_uint8) % uint8
% Z = imabsdiff(gray, gray_recon);
% Z = mat2gray(im2double(gray)-im2double(gray_recon));

%% Write new images
% imwrite (dct_I, 'Q3_diff.tiff');

%% Info 
im_diff = dir('Q3_diff.tiff').bytes

%% Show images
% figure, montage({gray,gray_recon});
figure, montage(image_comp);
% figure, imshow(Z, []);