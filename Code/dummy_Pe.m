function [BER_ZFOut_half_sine,BER_ZFOut_SRRC,BER_MMSEOut_half_sine,BER_MMSEOut_SRRC]=dummy_Pe(sigma)
% N = input('Enter number of 8x8 DCT blocks in a group!\n');
N=200/40;
% rolloff = input('Enter SRRC roll-off factor(alpha)!\n');
rolloff=0.5;
% K = input('Enter SRRC truncation length (K)!\n');
K=5;
span=2*K; % SRRC filter span
sps=32; % Number of samples per bit duation
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
    % h = [0.5 1 0 0.63 0 0 0 0 0.25 0 0 0 0.16 zeros([1 12]) 0.1]; % Outdoor
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
    L_ZFOut_SRRC= length(dummy_Det_ZFOut_SRRC) - N*p*q*8; % pos-choosing the first sample as the beginning of our sampling...
    Det_ZFOut_SRRC(:,i) = dummy_Det_ZFOut_SRRC((L_ZFOut_SRRC+1)/2:end-(L_ZFOut_SRRC+1)/2);

    Det_MMSEOut_half_sine(:,i) = Detection(MMSEOut_half_sine,sps);

    dummy_Det_MMSEOut_SRRC  = Detection(MMSEOut_SRRC,sps);
    L_MMSEOut_SRRC= length(dummy_Det_MMSEOut_SRRC) - N*p*q*8;
    Det_MMSEOut_SRRC(:,i)  =dummy_Det_MMSEOut_SRRC((L_MMSEOut_SRRC+1)/2:end-(L_MMSEOut_SRRC+1)/2);
end
%% 3.2.2 Effect of the pulse shaping function
% Performance Analysis Using BER:
BitStream(BitStream==-1)=0; % Convert antipodal data stream back to binary!
BER_ZFOut_half_sine=(sum(sum(BitStream~=Det_ZFOut_half_sine)))/numel(BitStream);
BER_ZFOut_SRRC=(sum(sum(BitStream~=Det_ZFOut_SRRC)))/numel(BitStream);
BER_MMSEOut_half_sine=(sum(sum(BitStream~=Det_MMSEOut_half_sine)))/numel(BitStream);
BER_MMSEOut_SRRC=(sum(sum(BitStream~=Det_MMSEOut_SRRC)))/numel(BitStream);
end