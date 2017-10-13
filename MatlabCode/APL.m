function out = APL(M, sig,fc,fs,att,g)
% Filtered signal : Delay + Lowpass + Gain
% M : delay length
% fc : cut-off frequency
% fs : sample frequency
% att : attenuation 
% g : feedback/feedforward coefficient

xdel = zeros(M,1);  % delay with length M
Z = [xdel' sig'];   % signal delayed

[b,a] = butter(2,fc/(fs/2));
LPF = filter(b,a,Z);

fSig = a*LPF;

fb = 0;
Y = [];

for i = 1:length(sig)

  y = g*sig(i)+fSig(i)+fb(i);
  fb = -g*y;

  Y(i,:) = y + fb;



end

end
