function out = MM(sig_in,alpha)
% Feedback delay Network
% Can be implemented as 3 parallel feedback comb filters
% with one new feedback path from the output to the input
% through a gain of -2/N

% N is the order of the filter
% alpha is the feedback gain

b = 0;
a = 4*alpha;

out = filter(b,a,sig_in);


% N     = 2;    % Order
% BW    = 1200;  % Bandwidth
% Apass = 1;     % Bandwidth Attenuation
%
% [b, a] = iircomb(N, BW/(Fs/2), Apass);
% Hd     = dfilt.df1(b, a);
%
% comb1 = filter(b,a,early_ref);
% comb2 =  filter(b,a,early_ref);
% comb3 =  filter(b,a,early_ref);
end
