function z = delayZ(in,M)
% DELAY
% sig: input signal
% M: delaytime in samples
% g: gain coefficient
% z: delayed signal added with input signal

% xdel = zeros(M,1);
% xnew = [xdel' sig'];
% z = g.*xnew;

h = dfilt.delay(M);
z = filter(h,in);
end


