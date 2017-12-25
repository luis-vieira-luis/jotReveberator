function c = comBBB(g,m,in)

b = [0 zeros(1,m-2) g];
a = [1 zeros(1,m-2) -g];

c = filter(b,a,in);
end
