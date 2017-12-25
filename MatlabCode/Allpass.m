function apf = Allpass(in, g, m)
% Schroeder allpass filter
%      in = the input signal
%      g = the feedforward gain (the feedback gain is the negative of this) (this should be less than 1 for stability)
%      m = the delay length
%      apf = the output signal
%      b = the numerator coefficients of the transfer function
%      a = the denominator coefficients of the transfer function

%If the feedback gain is more than 1, set it to 0.7 .
if g>=1
   g=0.7;
end

%Set the b and a coefficients of the transfer function depending on g and d.
b=[g zeros(1,m) 1];
a=[1 zeros(1,m) g];

%filter the input signal
apf=filter(b,a,in);

end
