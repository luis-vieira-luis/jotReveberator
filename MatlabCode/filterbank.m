function fb = filterbank(sig,N,M,g)
% Filter bank with N parallel combfilters
% N : order of the filter bank
% M : matrix with z(n) delay lenths
% g : gain

Stack = [];

for i = 1:1:N

    R = delayZ(sig(i),M(i),g); % recurssive part of feedback combfilter

    zeros_pad = zeros(1,6500 - length(R)); % buffer of 6500 samples maximum (random value for the moment)
    R_pad = [R zeros_pad];

    Stack(i,:) = [R_pad]; % store in matrix the values of the recurssive part
end

filterSum = sum(Stack); % parallel comb filters
fb = N./(3-filterSum); % transfer function with global recurssive gain N/2

end
