%% 2.10 Conversion to an image
function [ImageMatrix] = ImageConversion(Det_BitStream,m,n,p,q)
% Det_BitStream: Detected bit stream
% 8 by 8 blocks are used in this project
% p = 8;                                   
% q = 8;
% [m,n]: Image size [number of pixels]
%% Invert the reshaping operation
temp = reshape(Det_BitStream',p,length(Det_BitStream)/p,1); % Each column contains binary representation of a single DCT coefficient!
ImageMatrix = bi2de(temp');
ImageMatrix = reshape(ImageMatrix,p,q,(m*n)/(p*q));   % Reshape long column vector into 3D array composed of 8x8 DCT blocks
ImageMatrix = reshape(ImageMatrix,p,n,m/p);           
ImageMatrix = permute(ImageMatrix,[1 3 2]);
ImageMatrix = reshape(ImageMatrix,m,n);               % Reshape 3D array to 2D image matrix
end