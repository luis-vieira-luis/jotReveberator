close all

in =[1 zeros(1,3999)];
out = zeros(1,length(in));
Fs = 44100;

LPF = Lowpass(in,4,4000,Fs);
delayedInput = delayM2(LPF,100,0.7,100);

%
%------------------------------------------------------------------------%
% EARLY REFLECTIONS
tapdelays = [41 53 79 100]; % tap delaylines values (primes)
nTapdelay = length(tapdelays); % number of tap delays

% Delay attenuation coefficients
%bn = [0.9 0.7 0.68 0.55];
bn = [0.1 0.2 0.3 0.4];
% Allpass
allpassGain = 0.7;
allpassDelay = 10; % in samples

% Tapped delaylines
TDL_early = tdl(delayedInput,nTapdelay,bn,tapdelays);

% Allpass filter
allpassReflection = Allpass(TDL_early,allpassGain,allpassDelay);

% Early Reflections output
earlyRef = allpassReflection*0.6;
%%
%------------------------------------------------------------------------%
% LATE REVERB
% delay lengths for late reverb
del = [189 200 321 386 411 489 533];
g = [0.1 0.2 0.3 0.4 0.5 0.6 0.7]; % gain values for each delay
ndel = length(del);

% tapped delayline for late reverberation
TDL_late = tdl(delayedInput,ndel,g,del);

kn = [1 1 1 1 1 1 1];
att = 0.1;

abf6 = zeros(1,4000);

for i = 1:20
    
    %in = delayedInput + abf6;
    in = TDL_late + abf6;
    
    abf1 = abAllpass(in,del(1),g(1),kn(1),att);
    abf2 = abAllpass(abf1,del(2),g(2),kn(2),att);
    abf3 = abAllpass(abf2,del(3),g(3),kn(3),att);
    abf4 = abAllpass(abf3,del(4),g(4),kn(4),att);
    
    abd = abDelay(abf4,del(5),kn(5),att);
    
    abf5 = abAllpass(abd,del(6),g(6),kn(6),att);
    abf6 = abAllpass(abf5,del(7),g(7),kn(7),att);
    
    out = abf1+abf2+abf3+abf4+abf5+abf6;
    
end


y = in+earlyRef+out;

figure(1)
subplot(211)
plot(abf6)
subplot(212)
plot(out)

%------------------------------------------------------------------------%
%%

% with frame size

frameWin = 2;
frameSize = floor(length(in)/frameWin);

overlap = zeros(1,frameSize);

for i = 1:frameWin
    
    if i == 1
        frame = out(1:frameSize) + delayedInput(1:frameSize);
    else
        frame = out((i-1)*frameSize+1:i*frameSize) + ...
            delayedInput((i-1)*frameSize+1:i*frameSize);
    end
    
    filterInput = [frame zeros(1,frameSize)];
    
    abf1 = abAllpass(filterInput,del(1),g(1),kn,att);
    abf2 = abAllpass(abf1,del(2),g(2),kn,att);
    abf3 = abAllpass(abf2,del(3),g(3),kn,att);
    abf4 = abAllpass(abf3,del(4),g(4),kn,att);
    
    abd = abDelay(abf4,del(5),kn,att);
    
    abf5 = abAllpass(abd,del(6),g(6),kn,att);
    abf6 = abAllpass(abf5,del(7),g(7),kn,att);
    
    out(1,(i-1)*frameSize+1:frameSize*i) = abf6(1:frameSize)+overlap;
    overlap = abf6(frameSize+1:end);
   
end



