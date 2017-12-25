function abf = abAllpass(sig,M,g,k,att)
% Absorbent allpass filter
% It's defined as the series of a delay line, a lowpass filter and an
% attenuator. A general feedback and feedforward coefficient is applied in
% the end

% sig : input signal
% M : delay length
% g : feedback and feedforward coefficients
% k : lowpass filter coefficient
% att : attenuation coefficient

if g>=1
    g=0.9;
end

%If the low pass feedback gain is more than 1, set it to 0.7 .
if k>=1
    k=0.9;
end

%------------------------------------------------------------------------%
zero_padding = zeros(1, M);

% calculate coefficients
b = [g (-g)*k zero_padding (att-att*k)];
a = [1 -k zero_padding (g*att-g*att*k)];

% filter
abf = filter(b, a, sig);
end


