function [b,a,abf] = abAllpass(in,M,g, k,att)

N = length(M);
z_padding = zeros(1, N-3);


if g>=1
   g=0.7;
end

%If the low pass feedback gain is more than 1, set it to 0.7 .
if k>=1
   k=0.7;
end

% calculate coefficients
b = [g g*k z_padding (att-att*k)];
a = [1 k z_padding (g*att-g*att*k)];

% filter
abf = filter(b, a, in);


end
