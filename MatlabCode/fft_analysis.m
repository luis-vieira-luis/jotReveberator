clear all;
%%
load 'jungle.mat'

fs = 44100;  % sample freq
sig = jungle_L; % original sig
N = length(sig); % sample length
Ns = 2048; % number of points for fft

sig_fft = fft(sig,Ns); % fft analysis
freq = (0:Ns-1)*(fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db = 20*log10(mag);

figure(1)
subplot(311)
plot(sig)
subplot(3,1,2)
semilogx(freq,mag_db)
axis([20 20000 -100 0])
grid on

%%

% FFT analysis in blocks of 512 samples

Ns_block = 512; % number of points for ftt in each block
nr_block = floor(length(sig)/Ns_block);
freq_block = (0:Ns_block-1)*(fs/Ns_block);
win = hann(Ns_block);
mag_vec_block = [];

subplot(3,1,3)
hold on

for n = 0:nr_block-5

  sig_block = (sig(n*Ns_block+1:(n+1)*Ns_block));
  sig_fft_block = fft(sig_block);
  mag_block = abs(sig_fft_block);
  mag_db_block = 20*log10(mag_block);

  mag_vec_block = [mag_vec_block mag_db_block];

  semilogx(freq_block,mag_db_block)
  axis([20 20000 -100 0])
end
