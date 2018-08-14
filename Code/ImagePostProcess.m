function []=ImagePostProcess(newI,minval,maxval,p,q)

temp_unquant=newI/255;  % To invert quatization and get back to scaled DCT coefficients
temp=(temp_unquant)*(maxval-minval)+minval;  % Rescale using inverse of linear scaling from pre-processing stage
fun=@idct2;
Original_hat=blkproc(temp,[p q],fun);
Original_hat=uint8(Original_hat); % Convert from type double to uint8 before displaying image 
imshow(Original_hat);
end
