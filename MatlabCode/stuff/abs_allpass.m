
function y = abs_allpass(x)

g = .5;
b = [g sec1];
a = [1 g*sec1];
abs_allpass = filt.df1(b,a);
end
