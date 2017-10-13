function out = APL(M, sig,fc,fs,a,g,N)
% Filtered signal : Delay + Lowpass + Gain

xdel = zeros(M,1);  % delay with length M
Z = [xdel' sig'];   % signal delayed

[b,a] = butter(2,fc/(fs/2));
LPF = filter(b,a,Z);

fSig = a*LPF;

fb = 0;
Y = [];

for i = 1:N

  y = g*sig(i)+fSig(i)+fb(i);
  fb = -g*y;

  Y(i,:) = y + fb;



end

end
