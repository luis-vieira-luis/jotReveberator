%% ------ JOT REVERBERATOR ------ %%
clear all; close all;

% Lowpass filter
% Room HF : controls the high frequency attenuation
% Decay HF Ratio : ratio of high frequency decay time to low freq decay,
%                  adjusting the high freq attenuation of the lowpass
%                  filters in the absorbent delays and allpass filters

%-----------------------------------------------------------------------------%
%% INITIALIZE GLOBAL VARIABLES
%-----------------------------------------------------------------------------%

%load 'jungle.mat'


Fs = 44100; % sample frequency

in = [1, zeros(1,4000)]; % input signal
out = zeros(4000,1);     % output signal

roomHF = 18000;
% decayHF = ;
% hfReference = ;

% decayTime = ;
% reflLevel = ;
reflDelay = 1;

% revLevel = ;
 revDelay = 1; 
% spreadRef = 30; % percentage of spread between early reflections

% diffusion = ; % echo density
% density = ;   % modal density


%-----------------------------------------------------------------------------%
% EARLY REFLECTIONS
%-----------------------------------------------------------------------------%
% Initialize local variables

% Delaylines
tapdelays = reflDelay.*[149 211 263 293]'; % .*(((spreadRef/200)-1)*((1-spreadRef/200)^(-1))) tap delaylines values (prime values)
nTapdelay = length(tapdelays); % number of tap delays

% Delay attenuation coefficients
bn = [1 1 1 1];

%Allpass
allpassGain = 0.7;
allpassDelay = 200;

%-----------------------------------------------------------------------------%

% Lowpass air absorption
LPF = Lowpass(in,roomHF,Fs);

%-----------------------------------------------------------------------------%

% Tapped delaylines
TDL = tdl(LPF,nTapdelay,bn,tapdelays);

%-----------------------------------------------------------------------------%
% Allpass filter

allpassReflection = Allpass(TDL,allpassGain,allpassDelay);

%-----------------------------------------------------------------------------%
% Early Reflections output
earlyRef = allpassReflection*0.6;

plot(earlyRef)

%%
%-----------------------------------------------------------------------------%
% FEEDBACK DELAY NETWORK
%-----------------------------------------------------------------------------%
% Initialize local variables

gainFDN = 0.6; % g < 1; editable value for unitary poles in the matrix
gFeedbackMatrix = gainFDN/sqrt(2);
feedbackMatrix = gFeedbackMatrix.*[0 1 1 0; -1 0 0 -1; 1 0 0 -1; 0 1 1 0]; % Feedback matrix
% A = [a -a -a -a; -a a -a -a; -a -a a -a; -a -a -a a];

cn = [0.8 0.8 0.8 0.8];
gainAbsorbent = 0.5; % g
attenuation = 0.9; % attenuation (att)

%lateDelaylines = [6615 14200 18036 28047]; %39469 53096 78189]; % absorbent allpass delay length
lateDelaylines = revDelay.*[149 211 263 293];
kn = [0.9 0.6 0.5 0.4]; %0.6 0.3 0.2];


%-----------------------------------------------------------------------------%
% absorbent allpass filter
% H(z) = g - g*k*Z(-1) + (att-att*K)*Z(-m) / (1 - k*Z(-1) + ...
% (g*att-g*att*k)*Z(-m)

% y(n) = att*x(n-m) - att*k*x(n-m) + k*y(n-m)

% allpass coefficient (g in the diagram) is set as a function of Diffusion property.
% All the filters in the late reverberation processor have the same allpass coefficient
% It is calculated from the equation: g = maxallpass*(diffusion/100)
% maxallpass is defined as 0.61803

[b,a,h] = abAllpass(TDL,lateDelaylines(1),gainAbsorbent,kn(1),attenuation);


for i = 1:length(lateDelaylines)
    
    
    [b1,a1,h] = abAllpass(TDL,lateDelaylines(i),gainAbsorbent,kn(i),attenuation);
    h(i,:) = [h];
    [b,a] = seriescoefficients(b1,a1,b,a);
   
end

H = h';

% Absorbent Delay Lines
z1 = H(:,1)';
z2 = H(:,2)';
z3 = H(:,3)';
z4 = H(:,4)';




%%
% Feedback matrix
for n = 1:length(in)
    
    tmp = [z1(lateDelaylines(1)) z2(lateDelaylines(2)) z3(lateDelaylines(3)) ...
        z4(lateDelaylines(4))];
    
    fdn(n) = in(n) + cn(1)*z1(lateDelaylines(1))+ cn(2)*z2(lateDelaylines(2)) ...
        + cn(3)*z3(lateDelaylines(3)) + cn(4)*z4(lateDelaylines(4));
    
    z1 = [(in(n)*bn(1) + tmp*feedbackMatrix(1,:)') z1(1:length(z1)-1)];
    z2 = [(in(n)*bn(2) + tmp*feedbackMatrix(2,:)') z2(1:length(z2)-1)];
    z3 = [(in(n)*bn(3) + tmp*feedbackMatrix(3,:)') z3(1:length(z3)-1)];
    z4 = [(in(n)*bn(4) + tmp*feedbackMatrix(4,:)') z4(1:length(z4)-1)];
    
end


%-----------------------------------------------------------------------------%
%plot(fdn)

out = earlyRef + fdn';

%%
% Plotting

Ns = 2048; % number of points for fft

sig_fft = fft(out,Ns); % fft analysis
freq = (0:Ns-1)*(Fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db = 20*log10(mag);

figure(1)
subplot(311)
plot(earlyRef)
subplot(312)
plot(fdn)
subplot(313)
semilogx(freq,mag_db)
axis([20 30000 -100 20])
grid on
