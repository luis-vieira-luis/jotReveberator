function comb = iircomb(sig,M,g)
% IIR combfilter
% transfer function: (g*Z(-m)) / (1-g*Z(-m))
% sig : input signal
% M : delay length
% g : gain coeff


padding = zeros(1, M-1);
b = [0 padding g];
a = [1 padding -g];
comb = filter(b, a, sig);

end
