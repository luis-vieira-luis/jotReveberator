function z = delayM2(input,del,cn,maxdel)
% DELAY
% in: input signal
% M: delaytime in samples
% bn: gain coefficient
% z: delayed signal added with input signal



xdel= zeros(1,del);
%zpad = zeros(1,maxdel - del);


xnew = [xdel input(1:length(input)-del)]; 
z = cn.*xnew;
    
end
