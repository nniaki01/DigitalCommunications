%% 2.8 Equalizer
function [q_zf, q_mmse] = Equalizer(h_up,sigma)
% h_up : Upsampled channel
% sigma: Noise standard deviation
L = 4096; % 4096 or any power of 2 sufficiently large to approximate IIR filter!
H = fft(h_up,L); 
%% Zero-Forcing
Q_zf = 1./H;
q_zf = ifft(Q_zf,L);
%% MMSE
Q_MMSE= conj(H)./((abs(H).^2) + 2.*(sigma.^2));
q_mmse= ifft(Q_MMSE,L);
end