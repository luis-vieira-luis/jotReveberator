function outCbuff = ciruclarBuffer(sig,frameSize,bufferSize)

% define Virtual Soundcard
% [sig, fs] = audioread('qrt.WAV');
l = length(sig);
sigOut = zeros(l,1);

% define buffer specifications
% frameSize = 2048;
% bufferSize = frameSize*3;
buffer = zeros(bufferSize,1);

% % filtering specifications
% [b,a] = butter(6,900/fs);
% lengthLPF = frameSize*2;


% circularbuffer cursor 
% Note : cursorSoundCard is a virtual cursor for the sake of the exercise
cursor = 1;
cursorSoundCard = 1;

zeroPadding = zeros(frameSize,1);
 
% ------------------------------------------------------------------------%
% circular buffer

while 1
    
    pointerRead = generatePointers(cursor,frameSize,bufferSize);
    sigOut(cursorSoundCard:cursorSoundCard+frameSize-1,:) = buffer(pointerRead);
    
    buffer(pointerRead,:) = zeros(frameSize,1); 
    
    
    if cursorSoundCard + frameSize > l
        break;
    end
    
    cursorSoundCard = cursorSoundCard + 1;
    Frame = sig(cursorSoundCard : cursorSoundCard + frameSize-1);
    
    zeropadInput = [Frame'; zeroPadding];
    lpf = filter(b,a,zeropadInput);
    
    cursor = cursor + frameSize + 1;
    if cursor > bufferSize
        cursor = cursor - bufferSize;
    end
    
    pointerWrite = generatePointers(cursor,lengthLPF,bufferSize);
    buffer(pointerWrite) = lpf + buffer(pointerWrite);
    
    
end

soundsc(sigOut,fs)
