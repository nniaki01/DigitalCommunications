%% 2.3 Conversion to a bit stream
function [BitStream,nG]=Conv2Bit(N,I_reshaped,m,n,p,q)
% N Number of 8x8 DCT blocks in a group
nG = (m*n)/(p*q*N);                          % Number of groups
% Reshape in groups of size N
temp_long=zeros(nG,p*q*N); % nG long column vectors, each of size 8x8xN
BitStream=zeros(8*p*q*N,nG);
for i = 1:nG  
    temp=zeros(p,N*q);
    for j=1:N
        temp(:,(j-1)*q+1:j*q) = I_reshaped(:,:,(i-1)*N+j);
    end 
    temp_long(i,:) = reshape(temp,1,p*q*N);
end 
% 8*8*NxnG matrix where each column represents the corresponding group's DCT coefficients
temp_long=temp_long'; 
for i=1:nG
     R_temp = de2bi(temp_long(:,i),8); % Convert decimal to 8-bit binary
     R_temp = double(R_temp);          % Convert to double
     R_temp(R_temp==0) = -1;           % Antipodal scheme
     % Reshape to 8*8*N*8xnG matrix where each column represents the corresponding group's antipodal data stream
     BitStream(:,i) = reshape(R_temp',numel(R_temp),1);  
end                                                       
end