%% ------ JOT REVERBERATOR ------ %%
clear all; close all;
%%

load 'jungle.mat'

Fs = 44100;
Ns = 2048; % number of points for fft

sig = [1; zeros(3999,1)];
%[sig,fs] = audioread('flute_music.wav');
sig1 = jungle_L; % original sig


sig_fft = fft(sig1,Ns); % fft analysis
freq = (0:Ns-1)*(Fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db = 20*log10(mag);

%-----------------------------------------------------------------------------%
%% Plotting

figure(3)
subplot(311)
plot(sig)
title('ImpRes - Time Domain (samples)')

subplot(312)
plot(sig1)
title('Jungle - Time Domain (samples)')

subplot(313)
semilogx(freq,mag_db)
axis([20 20000 -100 0])
title('Jugle - FFT')
grid on

%-----------------------------------------------------------------------------%
%% Early Reflections
%-----------------------------------------------------------------------------%

% Lowpass filter
% attenuation at high frequency
roomHighFreq = 3000;
LPF = Lowpass(sig,roomHighFreq,Fs);
%%
%-----------------------------------------------------------------------------%
% Delay lines
% in samples

del = [661 970 1323 4410]; % tap delaylines values
bn = [0.8 0.5 0.3 0.1];     % delay attenuation coefficients

Z = [];
zeropad = max(del);
bufflength = length(LPF)+zeropad;

%%
for i = 1: 4
    y = delayZ(LPF,del(i),bn(i)); % delayline
    zpad = zeros(1,bufflength-length(y));
    y1 = [y zpad];
    Z(i,:) = [y1]; % store delaylines
end

% Tapped delay lines (y(n) = b0x(n)+bm1x(n-m1)+bm2x(n-m2)+bm3x(n-m3)
TDL = sum(Z)';

%-----------------------------------------------------------------------------%
% Allpass filter

g = 0.4;
N = 2;
APF = Allpass(TDL,g,N);

%-----------------------------------------------------------------------------%
early_ref = APF*0.6;    % early reflections output














%-----------------------------------------------------------------------------%
%% FEEDBACK DELAY NETWORK
%-----------------------------------------------------------------------------%
% H(z) = N / (3 - Sum(g*Z(M)))
% g = 0.7;
% A = g/(sqrt(2)).*[0 1 1 0; -1 0 0 -1; 1 0 0 -1; 0 1 -1 0]; % feedback matrix gains
% M = [244 353 457 1452]; % delay lengths
% bn = [0.8 0.5 0.3 0.3]; % gain coeff before delay lines
% cn = bn; % gain coeff after delay lines
% qn = [0.4 0.4 0.4 0.4];
% d = 0.5; % gain coeff direct signal
% D = diag(M); % diagonal matrix with delay lenghts
%
% H = bn.*(cn'.*(D-A))+d;


for i = 1:length(Z)
    
FDN = filterbank(Z(i),M(i),g_M(i));

end



























%-----------------------------------------------------------------------------%
%% LATE REVERBERATION
%-----------------------------------------------------------------------------%
% Absorbent Allpass filters in series

Mslength = [78189 53096 39469 28047 18036 14200 6615]; % absorbent allpass delay length
M_length = [1772 1203 894 635 409 321 150]; % delay lengths in ms
Tr = 2000; % decay time in ms
fc = 18000; % absorbent allpass cut-off frequency (HF reference value)
Diffusion  = 100;
HFratio = 0.3;

apl = []; % initialize vector

for i = 1:length(Mslength)

    abf = APL(M_length(i),Tr,HFratio,Diffusion,fc,Fs,FDN);
    apl(i,:) = [abf];
end
