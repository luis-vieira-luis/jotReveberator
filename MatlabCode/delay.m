function z = delay(in,m,bn)
% DELAY
% sig: input signal
% M: delaytime in samples
% g: gain coefficient
% z: delayed signal added with input signal

xdel= zeros(m,1);
xnew = [xdel' in];
z = bn.*xnew;
end
