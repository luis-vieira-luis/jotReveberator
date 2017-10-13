function apf = Allpass( in, g, N )
% Schroeder allpass filter
% INPUT
% in  : input signal
% g   : gain
% N   : order of the filter
% OUTPUT
% out : filtered signal

z_padding = zeros(1, N-1);
b = [-1 z_padding (1+g)];
a = [1 z_padding -g];
apf = filter(b, a, in);

%h = dsp.IIRFilter('Numerator',b,'Denominator',a);
%out = step(h,in);

% freqz(h)

end
