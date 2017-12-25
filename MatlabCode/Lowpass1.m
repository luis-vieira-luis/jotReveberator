%function lpf = Lowpass(in,roomHF,fc,fs)
function lpf = Lowpass1(in,kn)
% 2nd order lowpass filter with cutoff adjustable by the user
% normalized for a range of [0 Fs/2]

b = [1-kn 0];
a = [1 -kn];
%[b,a] = butter(roomHF,fc/(fs/2),'low');
lpf = filter(b,a,in);
end
