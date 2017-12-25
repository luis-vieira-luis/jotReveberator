function c = combLPF(g,k,m,in)


b = [0 0 zeros(1,m-3) g-g*k];
a = [1 -k zeros(1,m-3) g*k-g];

c = filter(b,a,in);

end
