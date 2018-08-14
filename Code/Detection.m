%% 2.9 Detection
function [output] = Detection(input,sps)
% sps: Number of samples per bit duration
output = input(sps:end);
output = downsample(output,sps);

for i = 1:length(output)
    if output(i) > 0
        output(i) = 1;
    else
        output(i) =0;
    end
end
output = output';
end