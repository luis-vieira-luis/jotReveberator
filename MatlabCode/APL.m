function out = APL(in,M,k,g,at)
% absorbent allpass filter
% M : delay length in samples
% at : attenuation coefficient (associated with delay and LPF)
% g : feedback and feedforward coefficient
% k : coefficient lowpass filter

%------------------------------------------------------------------------%
% creating filter

z_padding = zeros(1, (M-3));
b = [g z_padding (-g)*k (at-at*k)];
a = [1 z_padding -k (g*at-g*at*k)];
out = filter(b, a, in);


end
