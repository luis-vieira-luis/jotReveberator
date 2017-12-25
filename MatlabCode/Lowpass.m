function lpf = Lowpass(in,roomHF,fc,fs)
% 2nd order lowpass filter with cutoff adjustable by the user
% normalized for a range of [0 Fs/2]


[b,a] = butter(roomHF,fc/(fs/2),'low');
lpf = filter(b,a,in);
end
