function abdel = abDelay(sig,M,k,att)

%If the low pass feedback gain is more than 1, set it to 0.7 .
if k>=1
    k=0.7;
end

%------------------------------------------------------------------------%
zero_padding = zeros(1, M);

% calculate coefficients
b = [0 0 zero_padding (att-att*k)];
a = [1 (-k) zero_padding 0];

% filter
abdel = filter(b, a, sig);
end
