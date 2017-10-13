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

%% Lowpass filter
% attenuation at high frequency
roomHighFreq = 3000;
LPF = Lowpass(sig,roomHighFreq,Fs);

%-----------------------------------------------------------------------------%
%% Delay lines
% in samples

del = [661 970 1323 4410]; % tap delaylines values
c = [0.8 0.5 0.3 0.1];     % delay attenuation coefficients

Z = [];

for i = 1: 4
    y = c(i)*delay(LPF,del(i));
    Z(i,:) = [y]; % delay lines
end

% TDL
TDL = sum(Z)';

%-----------------------------------------------------------------------------%
%% Allpass filter

g = 0.4;
N = 2;
APF = Allpass(TDL,g,N);

%-----------------------------------------------------------------------------%
direcSig = APF*0.6;    % early reflections output

%-----------------------------------------------------------------------------%
%% FEEDBACK DELAY NETWORK
%-----------------------------------------------------------------------------%
% H(z) = N / (3 - Sum(g*Z(M)))

M = [457 1452 353];
g_M = 0.7;

FDN = filterbank(Z,3,M,g_M);

%-----------------------------------------------------------------------------%
%% LATE REVERBERATION
%-----------------------------------------------------------------------------%
%% Absorbent Allpass Filter

g1 = 0.7;
atten = 0.1;
del = [2221 1993 1723 227 173 569];
Fpass_a = 15000;
Fstop_a = 16000;

%% Late Reverberation

abp1 = ABPF(FDN,atten);
abp2 = ABPF(abp1,atten);
abp3 = ABPF(abp2,atten);
abp4 = ABPF(abp3,atten);

z4 = delay(abp4,14000);
lpf_j = Lowpass(z4,Fs,2,16000,17000);

abp5 = 0.5*ABPF(lpf_j,atten);
abp6 = ABPF(abp5,atten);

tapp = abp1+abp2+abp3+abp4+abp5+abp6;

late_rev = tapp + abp6 * 0.8;

%%

SUM_out = early_ref + late_rev;


[freq_f_s,mag_db_f_s] = ffourier(Fs,SUM_out);

figure(4)
subplot(211)
plot(SUM_out)
subplot(212)
semilogx(freq_f_s,mag_db_f_s)
axis([20 20000 -100 0])




%soundsc(SUM_out,Fs)
