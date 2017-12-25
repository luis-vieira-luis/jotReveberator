function outCbuff = ciruclarBuffer(sig,frameSize,bufferSize)

% define Virtual Soundcard
l = length(sig);
sigOut = zeros(l,1);

% define buffer specifications
buffer = zeros(bufferSize,1);

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

outCbuff = sigOut;
