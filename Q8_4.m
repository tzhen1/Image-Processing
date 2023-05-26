clc;clear all;close all;

%% image read
RGB = imread('4.2.01.tiff');
%% split RGB channels
YCbCr = rgb2ycbcr(RGB);
Y = YCbCr(:,:, 1);
[rows, cols] = size(Y);
row = rows / 8;
col = cols / 8;

sr = 1; % size row
%% quantisation table for luminance, filter high freq
q_y = [16 11 10 16 24 40 51 61;
       12 12 14 19 26 58 60 55;
       14 13 16 24 40 57 69 56;
       14 17 22 29 51 87 80 62;
       18 22 37 56 68 109 103 77;
       24 35 55 64 81 104 113 92;
       49 64 78 87 103 121 120 101;
       72 92 95 98 112 100 103 99];

%% DCT
for i=1:row
    sc = 1; % size column
    for j=1:col
        block = Y(sr:sr+7,sc:sc+7); % 8x8 block of gray
        cent = double(block) - 128; % centered by -128
        for m=1:8 % row
            for n=1:8 % col
                if m == 1
                    u = 1/sqrt(8); %
                else
                    u = sqrt(2/8);
                end
                if n == 1
                    v = 1/sqrt(8);
                else
                    v = sqrt(2/8);
                end
                comp = 0;
                for x=1:8
                    for y=1:8
                        comp = comp + cent(x, y)*(cos((((2*(x-1))+1)*(m-1)*pi)/16))*(cos((((2*(y-1))+1)*(n-1)*pi)/16)); % equation
                    end
                end
                  F(m,n) = v*u*comp;
              end
          end
          for x=1:8
              for y=1:8
                  cq(x, y) = round(F(x, y)/q_y(x, y)); % quantisation
              end
          end
          Q(sr:sr + 7,sc:sc + 7) = cq; % 8x8 quantised block
          sc = sc + 8;
      end
      sr = sr + 8;
end

%% inverse DCT

sr = 1;
for i=1:row
    sc = 1;
    for j=1:col
        cq = Q(sr:sr+7,sc:sc+7); % 8x8 block
        for x=1:8
            for y=1:8
                dequant(x, y) = q_y(x, y)*cq(x, y);  % dequantise
            end
        end
        for x = 1:8
        for y = 1:8
            comp = 0;
            for m = 1:8
                for n = 1:8
                    if m == 1
                        u = 1/sqrt(2); % u = 0 to 7, sum between
                    else
                        u = 1;
                    end
                    if n == 1
                        v = 1/sqrt(2); % v = 0 to 7, sum
                    else
                        v = 1;
                    end
                        comp = comp + u*v*dequant(m, n)*(cos((((2*(x-1))+1)*(m-1)*pi)/16))*(cos((((2*(y-1))+1)*(n-1)*pi)/16));
                    end
                end
                  restore_res(x, y)=  round((1/4) *comp + 128); % + 128 to result
              end
           end
           Final_Image(sr:sr+7,sc:sc+7) = restore_res;% final image
           sc = sc + 8;
      end
      sr = sr + 8;
end

%% image diff
Z = imabsdiff(double(Y), Final_Image);

%% image write
imwrite(uint8(Final_Image), 'Q8_2.tiff');

%% image show
figure, imshow(uint8(Final_Image));
figure, imshow(Z, []); % slightly bigger size, retains abit more quality