[sig,fs] = audioread('qrt.WAV');


% lowpass filter coefficients
[b,a] = butter(6,14000/(fs/2));


%% with "clic"

% for i = 1:frameWin-2

%     % frame: virtual input of the soundcard
%     frame = sig((frameSize*(i-1))+1:(frameSize*i),1);
%
%     % filtering of the signal
%      lpf = filter(b,a,filterLPF);
%
%
%     % calculate how nmany samples are in the frame in each iteration
%     samplesinFrame = l-(frameSize*i);
%
%     % if number of samples in the frame is less than 2048
%     if samplesinFrame < frameSize && samplesinFrame > 0
%
%         zeropadding = zeros((frameSize - samplesinFrame),1);
%         frame = [sig((frameSize*(frameWin-1)):end-1,1); zeropadding];
%         lpf = filter (b,a,frame);
%
%     end
%
%     % virtual ouput of soundcard
%     sigOut((frameSize*(i-1))+1:(frameSize*i)*2,1) = lpf;
%
% end

%% with overlapp - adding method

overlap = zeros(frameSize,1);

for i = 1:frameWin-1

    % frame : virtual input of the soundcard
    frame = sig((frameSize*(i-1))+1:(frameSize*i),1);

    % filtering of the signal
    filterLPF = [frame; zeros(frameSize,1)]; % zeropadded frame
    lpf = filter(b,a,filterLPF); % filtered signal

    % calculate how many samples are in the frame in each iteration
    samplesinFrame = l-(frameSize*i);

    % if number of samples in the frame is less than 2048
    if samplesinFrame < frameSize && samplesinFrame > 0
        zeropadding = zeros((frameSize - samplesinFrame),1);
        frame = [sig((frameSize*(frameWin-1)):end-1,1); zeropadding];
        lpf = filter (b,a,frame);
    end


    % sigOut : virtual ouput of soundcard
    sigOut((frameSize*(i-1))+1:(frameSize*i),1) = lpf(1:frameSize)+overlap;

    overlap = lpf(frameSize+1:end);

end

    soundsc(sigOut,fs)

    
%% Plotting FFT analysis

N = length(sigOut); % sample length
Ns = 2048; % number of points for fft

sig_fft = fft(sigOut,Ns); % fft analysis
freq = (0:Ns-1)*(fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db = 20*log10(mag);

figure(1)
semilogx(freq,mag_db)
axis([20 20000 -100 0])
grid on
