function pointers = generatePointers(currentPosition,pointersSize,bufferSize)

if currentPosition+pointersSize-1 <= bufferSize
    
    pointers = currentPosition : currentPosition+pointersSize-1;
    
else
    
    pointers = [currentPosition : bufferSize, 1:(currentPosition+pointersSize-1)-bufferSize];
    
end
