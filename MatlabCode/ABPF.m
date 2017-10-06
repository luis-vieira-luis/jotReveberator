function out = ABPF(sig_in,atten)

b = 0;
a = atten;

y = filter(b,a,sig_in);

out = y;

end
