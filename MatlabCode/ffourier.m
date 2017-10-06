function [freq_f,mag_db_f] = ffourier(fs,sig)
% Fast Fourier analysis of signal with a 2048 points window.
% N corresponds to the sample length
% Ns corresponds to the number of points for fft

%N = length(sig);
Ns = 2048;

sig_fft = fft(sig,Ns); % fft analysis
freq_f = (0:Ns-1)*(fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db_f = 20*log10(mag);
end
