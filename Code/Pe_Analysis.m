%% Pe, Probability of error Analysis
clear 
close all
clc
Noise_std=[0;0.01;0.04;0.06;0.08;0.1;0.13;0.16;0.2;0.3;0.4;0.6;0.8;1];
Pe_ZF_hs=zeros(size(Noise_std));
Pe_ZF_SRRC=zeros(size(Noise_std));
Pe_MMSE_hs=zeros(size(Noise_std));
Pe_MMSE_SRRC=zeros(size(Noise_std));
for j=1:length(Noise_std)
    [Pe_ZF_hs(j,1),Pe_ZF_SRRC(j,1), Pe_MMSE_hs(j,1),Pe_MMSE_SRRC(j,1)]=dummy_Pe(Noise_std(j,1));
end
plot(Noise_std,Pe_ZF_hs,'r.-.','LineWidth',3)
grid on
hold on
plot(Noise_std,Pe_ZF_SRRC,'b.-.','LineWidth',2.5)
plot(Noise_std,Pe_MMSE_hs,'g.-.','LineWidth',3)
plot(Noise_std,Pe_MMSE_SRRC,'m.-.','LineWidth',2)
xlabel('\sigma')
ylabel('p_e')
title('Performance Analysis of Different Pulse Shaping Functions and Equalizers')
legend('ZF-Half-sine','ZF-SRRC','MMSE-Half-sine','MMSE-SRRC')