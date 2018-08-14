close all
clear
clc
%% Ask user to input project parameters!
% N = input('Enter number of 8x8 DCT blocks in a group!\n');
N=200/40;
% rolloff = input('Enter SRRC roll-off factor(alpha)!\n');
rolloff=0.5;
% K = input('Enter SRRC truncation length (K)!\n');
K=4;
% sigma = input('Enter noise standard deviation!\n');
sigma=0.05;
span=2*K; % SRRC filter span
sps=32; % Number of samples per bit duration
filename='200.jpg'; % TX image filename.fmt
%% 2.2 Image pre-processing
[I_reshaped,r,c,m,n,minval,maxval,p,q]=ImagePreProcess(filename);
%% 2.3 Conversion to a bit stream
[BitStream,nG]=Conv2Bit(N,I_reshaped,m,n,p,q);
%% Communication System
Det_ZFOut_half_sine=zeros(8*p*q*N,nG);
Det_MMSEOut_half_sine=zeros(8*p*q*N,nG);
for i=1:nG
    %% 2.4 Modulation
    [ModSignal_SRRC,g_SRRC,t_SRRC,ModSignal_half_sine,g_half_sine,t_half_sine]=PulseShaping(BitStream(:,i),sps, rolloff,span);
    %% 2.5 Channel
    h=[1 0.5 0.75 -2/7];
    % h = 1; % Perfect channel
%     h = [1 0.5 0 0.63 0 0 0 0 0.25 0 0 0 0.16 zeros([1 12]) 0.1]; % Flipped Outdoor
%     h = [0.5 1 0 0.63 0 0 0 0 0.25 0 0 0 0.16 zeros([1 12]) 0.1]; % Actual Outdoor
% h = [1 0.4365 0.1905 0.0832 0 0.0158 0 0.003];                % Indoor
    h_up = upsample(h,sps);
    ChOut_half_sine = filter(h_up,1,ModSignal_half_sine);
    ChOut_SRRC = filter(h_up,1,ModSignal_SRRC);
    %% 2.6 Noise
    NoisyOut_half_sine=ChOut_half_sine+sigma*randn(size(ChOut_half_sine));
    NoisyOut_SRRC=ChOut_SRRC+sigma*randn(size(ChOut_SRRC));
    %% 2.7 Matched Filter
    [MFOut_half_sine,MFOut_SRRC] = MatchedFilter(NoisyOut_half_sine,NoisyOut_SRRC,g_SRRC,g_half_sine);
    %% 2.8 Equalizer
    [q_zf, q_mmse] = Equalizer(h_up,sigma);
    ZFOut_half_sine = conv(q_zf,MFOut_half_sine);
    ZFOut_half_sine=ZFOut_half_sine(1:end-length(q_zf)+1);
    ZFOut_SRRC = conv(q_zf,MFOut_SRRC);
    ZFOut_SRRC =ZFOut_SRRC(1:end-length(q_zf)+1);
    MMSEOut_half_sine = conv(q_mmse,MFOut_half_sine);
    MMSEOut_half_sine=MMSEOut_half_sine(1:end-length(q_mmse)+1);
    MMSEOut_SRRC = conv(q_mmse,MFOut_SRRC);
    MMSEOut_SRRC=MMSEOut_SRRC(1:end-length(q_mmse)+1);
    %% 2.9 Detection
    Det_ZFOut_half_sine(:,i) = Detection(ZFOut_half_sine,sps);

    dummy_Det_ZFOut_SRRC= Detection(ZFOut_SRRC,sps);
    L_ZFOut_SRRC= length(dummy_Det_ZFOut_SRRC) - N*p*q*8; % position,choosing the first sample as the beginning of our sampling...
    Det_ZFOut_SRRC(:,i) = dummy_Det_ZFOut_SRRC((L_ZFOut_SRRC+1)/2:end-(L_ZFOut_SRRC+1)/2);

    Det_MMSEOut_half_sine(:,i) = Detection(MMSEOut_half_sine,sps);

    dummy_Det_MMSEOut_SRRC  = Detection(MMSEOut_SRRC,sps);
    L_MMSEOut_SRRC= length(dummy_Det_MMSEOut_SRRC) - N*p*q*8;
    Det_MMSEOut_SRRC(:,i)  =dummy_Det_MMSEOut_SRRC((L_MMSEOut_SRRC+1)/2:end-(L_MMSEOut_SRRC+1)/2);
end
%%
long_ZF_half_sine = reshape(Det_ZFOut_half_sine,numel(Det_ZFOut_half_sine),1);
long_ZF_SRRC = reshape( Det_ZFOut_SRRC,numel( Det_ZFOut_SRRC),1);
long_MMSE_half_sine = reshape(Det_MMSEOut_half_sine,numel(Det_MMSEOut_half_sine),1);
long_MMSE_SRRC = reshape(Det_MMSEOut_SRRC,numel(Det_MMSEOut_SRRC),1);
%% 2.10 Conversion to an image
Conv_ZFOut_half_sine = ImageConversion(long_ZF_half_sine,m,n,p,q);
Conv_ZFOut_SRRC= ImageConversion(long_ZF_SRRC,m,n,p,q);
Conv_MMSEOut_half_sine= ImageConversion(long_MMSE_half_sine,m,n,p,q);
Conv_MMSEOut_SRRC =ImageConversion(long_MMSE_SRRC,m,n,p,q); 
%% 2.11 Image post-processing
figure
subplot(2,3,1)
imshow(filename)
title('Original Image')
[Original]=imread(filename);    % Load color/grayscale image
[~ , ~, numOfColorCh] = size(Original);
if numOfColorCh > 1 % Convert to grayscale if colored otherwise leave as is.
    I = rgb2gray(Original);
else
    I = Original; 
end
subplot(2,3,4)
imshow(I)
title('TX Image')
subplot(2,3,2)
ImagePostProcess(Conv_ZFOut_half_sine,minval,maxval,p,q)
title(['ZF- Half-sine-\sigma_n=' num2str(sigma)])
subplot(2,3,3)
ImagePostProcess(Conv_ZFOut_SRRC,minval,maxval,p,q)
title(['ZF- SRRC-\sigma_n=' num2str(sigma)])
subplot(2,3,5)
ImagePostProcess(Conv_MMSEOut_half_sine,minval,maxval,p,q)
title(['MMSE- Half-sine-\sigma_n=' num2str(sigma)])
subplot(2,3,6)
ImagePostProcess(Conv_MMSEOut_SRRC,minval,maxval,p,q)
title(['MMSE- SRRC-\sigma_n=' num2str(sigma)])
