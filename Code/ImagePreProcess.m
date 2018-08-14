%% 2.2 Image pre-processing
function [I_reshaped,r,c,m,n,minval,maxval,p,q]=ImagePreProcess(file_name)
[Original]=imread(file_name);    % Load color/grayscale image
[~ , ~, numOfColorCh] = size(Original);
if numOfColorCh > 1 % Convert to grayscale if colored otherwise leave as is.
  I = rgb2gray(Original);
else
  I = Original; 
end

[m,n] = size(I);                         % Image size [number of pixels]

% 8 by 8 blocks are used in this project
p = 8;                                   
q = 8;
%% 2.2.2 Image pre-processing
% DCT on 8x8 blocks
fun = @dct2;
temp=blkproc(I,[p q],fun);
% Scale DCT coefficients linearly to [0,1]
minval = min(temp(:)); % Smallest value
maxval = max(temp(:)); % Largest value
temp_scaled = (temp-minval)/(maxval-minval);
% Quantize DCT coefficients to 256 levels
temp_quant=im2uint8(temp_scaled);
% Reshape to a 3D array: 8 x 8 x m*n/64
temp_reshaped = reshape(temp_quant,[p m/p n]);
temp_reshaped = permute(temp_reshaped,[1 3 2]);                  
I_reshaped = reshape(temp_reshaped,[p q m*n/(p*q)]);
r=floor(m/8);c=floor(n/8);
end