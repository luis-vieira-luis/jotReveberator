
function out = Lowpass(sig,Fs,N,Fpass,Fstop)
% LowpassFilter Design %%
% Fs is the sampling frequency
% N is the filter order
% Fpass is the passband-edge frequency is 8 kHz

filtertype = 'IIR';   % filter type
Rp = 0.01;            % passband ripple is 0.01 dB
Astop = 80;           % stopband attenuation is 80 dB


LP_IIR = dsp.LowpassFilter('SampleRate',Fs,...
    'FilterType',filtertype,...
    'PassbandFrequency',Fpass,...
    'PassbandRipple',Rp, ...
    'StopbandFrequency',Fstop,...
    'PassbandRipple',Rp,...
    'StopbandAttenuation',Astop);

out = LP_IIR(sig);

end
