function [y,b,a]=tdl(x,n,g,d)

%This is a tapped delay line function.
%
%The structure is:  [y,b,a] = tdl(x,n,g,d)
%
%where x = the input signal
%      n = the number of taps
%      g = a vector which contains the gain of each tap
%      d = a vector which contains the delay length of each tap
%      y = the output signal
%      b = the numerator coefficients of the transfer function
%      a = the denominator coefficients of the transfer function
%
% note: Make sure that d and g are the same length and that this length is n.


%find the maximum delay length
maxd=max(d);

%Set the b and a coefficients of the transfer function depending on g and d.
b=[1 zeros(1,maxd)];

for k = 1:n
   b = b + [zeros(1,d(k)) g(k) zeros(1,maxd-d(k))];
end

a=1;

%filter the input signal
y=filter(b,a,x);
