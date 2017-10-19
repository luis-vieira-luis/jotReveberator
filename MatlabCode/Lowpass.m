function lpf = Lowpass(in,decayHighRatio,fs)
    % 2nd order lowpass filter with cutoff adjustable by the user
    % normalized for a range of [0 Fs/2]
    [b,a] = butter(2,decayHighRatio/(fs/2));
    lpf = filter(b,a,in);
end
