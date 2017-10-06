%% ------ JOT REVERBERATOR ------ %%
clear all; close all;
%%

load 'jungle.mat'

Fs = 44100;
Ns = 2048; % number of points for fft

sig = [1; zeros(3999,1)];
sig1 = jungle_L; % original sig


sig_fft = fft(sig1,Ns); % fft analysis
freq = (0:Ns-1)*(Fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db = 20*log10(mag);

%% Lowpass filter

N=2;
Fpass = 19300;
Fstop = 19600;
lpf = Lowpass(sig,Fs,N,Fpass,Fstop);

%f1 = ffourier(Fs,lpf);

%% Delay lines
% in samples

del = 661;
del1 = 970;
del2 = 1323;
del3 = 4410;

z = delay(lpf,del);
z1 = delay(lpf,del1);
z2 = delay(lpf,del2);
z3 = delay(lpf,del3);

Z = z*0.9+z1*0.6+z2*0.4+z3*0.2;

%% Allpass filter

g = 0.4;
N = 2;
ap = Allpass(Z,g,N);

%% Early Reflections

early_ref = ap*0.6;    % early reflections output

%%
close all;

[freq_f,mag_db_f] = ffourier(Fs,early_ref); % fft analysis

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
hold on
% semilogx(freq_f,mag_db_f)
% title('ImpResp / Jugle - FFT')
axis([20 20000 -100 0])
grid on

%% Feedback Delay Network

N_fnd = 3;
alpha = -2/N_fnd;
FDN = MM(early_ref,alpha);


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
