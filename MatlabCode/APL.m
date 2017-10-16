function out = APL(M, sig,fc,Fs,att,g,b)
% absorbent allpass filter
% Filtered signal : Delay + Lowpass + Gain
% M : delay length in samples
% fc : cut-off frequency
% fs : sample frequency
% att : attenuation coefficient
% g : feedback and feedforward coefficient

xdel = zeros(M,1);  % delay with length M
Z = [xdel' sig'];   % signal delayed

[~,a] = butter(2,fc/(Fs/2)); % lowpass coefficients
LPF = filter(b,a,Z); % lowpass filter


zeros_pad = zeros(M,1);
Sig_pad = [sig'  zeros_pad']; % resize input size to match the filtered signal
y = g.*Sig_pad' + att.*LPF'; % g.x(n) + filtered signal (delay+lowpass+att)


fb = y*(-g); % feedback signal

out = y - fb; % absorbent allpass filter output

end
