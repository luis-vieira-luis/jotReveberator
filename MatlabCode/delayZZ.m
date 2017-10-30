function z = delay(in,M,g)
% DELAY
% sig: input signal
% M: delaytime in samples
% g: gain coefficient
% z: delayed signal added with input signal

z = g*[zeros(M,1)' in];
end
