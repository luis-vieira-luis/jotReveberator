frameLength = 256;

fileReader = dsp.AudioFileReader(...
    'qrt.wav',...
    'SamplesPerFrame',frameLength);

deviceWriter = audioDeviceWriter(...
    'SampleRate',fileReader.SampleRate);

Delay = dell(...
    'SampleRate',fileReader.SampleRate,...
    'dellay',300);


while ~isDone(fileReader)
    signal = fileReader();
    noisySignal = signal + 0.0025*randn(frameLength,1);
    processedSignal = Delay(noisySignal);
    deviceWriter(processedSignal);
    scope([noisySignal,processedSignal]);
end

release(fileReader);
release(deviceWriter);
release(scope);
release(Delay);