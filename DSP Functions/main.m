% ---------------------------------------------------------------------- %
% Jot Revererator
% DSP System Toolbox Implementation
% ---------------------------------------------------------------------- %

afr = dsp.AudioFileReader('qrt.WAV');
adw = audioDeviceWriter('SampleRate', afr.SampleRate);

Fs = afr.SampleRate;

%%
% ---------------------------------------------------------------------- %
% initialize global variables 
roomHF = 3; %order of the filter
decayHF = 1; % ratio of decay between high and low freq [0. : 1.]
hfReference = 300; %frequency control in Hz

decayTime = 1;
reflLevel = 0.6;
reflDelay = 1;

revLevel = 1;
revDelay = 0;
% spreadRef = 30; % percentage of spread between early reflections

diffusion = 90; % echo density in percentage
density = 1;   % modal density

% ---------------------------------------------------------------------- %
% initialize local variables (early reflections)

tapdelays = reflDelay.*[149 211 263 293]'; % tap delaylines values (primes)
nTapdelay = length(tapdelays); % number of tap delays

% Delay attenuation coefficients
bn = reflLevel*[1 1 1 1];

%Allpass
allpassGain = 0.7;
allpassDelay = 10; % in samples

%Lowpass
filtertype = 'IIR';

lpf = dsp.LowpassFilter('SampleRate',Fs,...
    'FilterType',filtertype,...
    'DesignForMinimumOrder',false,...
    'FilterOrder',roomHF,...
    'PassbandFrequency',hfReference);

% ---------------------------------------------------------------------- %


while ~isDone(afr)
    in = afr();
    
    LPF = lpf(in);
    adw(LPF);
    
end



release(afr); 
release(adw);
