function fb = filterbank(sig,P,g)
% Filter bank with N parallel combfilters
% N : order of the filter bank
% M : matrix with z(n) delay lenths
% g : gain

l = length(sig);
for n = 1:l
    p_comb = (P*g*Z(i))/(1-g*Z(i)+(2/P)*g*Z(i)); % transfer function for N parallel combfilters
end

end
