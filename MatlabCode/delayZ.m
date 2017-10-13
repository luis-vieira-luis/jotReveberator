function z = delayZ(sig,M,g)
%DELAY 
% x: input signal
% dt: delaytime in samples
% g: gain coefficient
% out: delayed signal added with input signal

xdel = zeros(M,1);
xnew = [xdel' sig'];
z = g*xnew;
end
