%% 2.7 Matched Filter
function [MFOut_half_sine,MFOut_SRRC] = MatchedFilter(RxSignal_half_sine,RxSignal_SRRC,g_SRRC,g_half_sine)
% RxSignal_ : Received Signal After passing through the channel
% g_*        : Matched filter impulse response
MFOut_half_sine = conv(g_half_sine,RxSignal_half_sine);
MFOut_SRRC= conv(g_SRRC,RxSignal_SRRC);
end