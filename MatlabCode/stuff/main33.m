%------------------------------------------------------------------------%
%% JOT REVERBERATOR
%------------------------------------------------------------------------%

clear all; 
close all;

%------------------------------------------------------------------------%
%% INITIALIZE GLOBAL VARIABLES
%------------------------------------------------------------------------%

Fs = 44100; % sample frequency

input = [1, zeros(1,3999)]; % input signal
output = zeros(4000,1);     % output signal

roomHF = 5; %order of the filter
decayHF = 0.9; % ratio of decay between high and low freq [0. : 1.]
hfReference = 18999; %frequency control in Hz

decayTime = 0.9; % in milliseconds
reflLevel = 1; % between 0 - 1
reflDelay = 1; % scale the tap delays

revLevel = 0.3; % between 0 - 1
revDelay = 0;
% spreadRef = 30; % percentage of spread between early reflections

diffusion = 100; % echo density in percentage
density = 1;   % modal density

% direct input gain coefficient
Bn = 0.3;

%------------------------------------------------------------------------%
% Lowpass and delay input signal for early reflections and late reverb  

% Lowpass air absorption
LPF = Lowpass(input,roomHF,hfReference,Fs);

% Delayed input signal
inputDelayed = delayM2(LPF,300,0.999,length(output));


%------------------------------------------------------------------------%
%% EARLY REFLECTIONS
%------------------------------------------------------------------------%
% Delaylines
tapdelays = reflDelay.*[41 53 79 149]'; % tap delaylines values (primes)
nTapdelay = length(tapdelays); % number of tap delays

% Delay attenuation coefficients
bn = reflLevel*[0.9 0.7 0.68 0.55];

%Allpass
allpassGain = 0.7;
allpassDelay = 10; % in samples

% Tapped delaylines
TDL = tdl(inputDelayed,nTapdelay,bn,tapdelays);

%------------------------------------------------------------------------%
% Allpass filter
allpassReflection = Allpass(TDL,allpassGain,allpassDelay);

%------------------------------------------------------------------------%
% Early Reflections output
earlyRef = allpassReflection*0.6;


%------------------------------------------------------------------------%
%% FEEDBACK DELAY NETWORK
%------------------------------------------------------------------------%
% Initialize local variables

% delay values for late reverberation
lateDelaylines = revDelay+density.*[239 457 600 673 711 783 917]; 
lateDelaylinesR = revDelay+density.*[258 493 622 685 736 799 952]; 

% --- %

gainFDN = 0.9999; % g < 1; editable value for unitary poles in the matrix
gFeedbackMatrix = gainFDN/sqrt(2);
r = 0;
% unitary matrix
U = gFeedbackMatrix.*[sin(r) cos(r); -cos(r) sin(r)];

maxallpass = 0.61803;
gainAbsorbent = maxallpass*(diffusion/100); % g


dlength = lateDelaylines*100/Fs;
attenuationDb = -60*(dlength/decayTime);
attenuation = 0.7; % attenuation (att)


% lowpass filter coefficient in the absorbent filters

dBGainFc = (-60*dlength)/(hfReference*decayTime);
G = 10.^(dBGainFc/20);
if G == 1
    b = 0;
else
    omega = cos(2*pi*hfReference/Fs);
    A = 8*G - 4*G*G' - 8*G*omega + 4*G*G'*omega*omega;
    b = (2*omega-2+sqrt(A)) / (2*G-2);
    
    if b > 1
        b = 1;
    end
    if b < 0 
        b = 0;
    end
end
kn = [0.1 0.1 0.1 0.1 0.1 0.1 0.1]; 

% Absorbent all-pass series (7 filters)
[H_L,tapoutL] = lateReverb(inputDelayed, lateDelaylines,...
    gainAbsorbent,kn,attenuation);
[H_R,tapoutR] = lateReverb(inputDelayed, lateDelaylinesR,...
    gainAbsorbent,kn,attenuation);
 
%------------------------------------------------------------------------%
% Feedback matrix

%init variables for loop
hnew_L = zeros(1,length(input));
H_L = hnew_L;
hnew_R= hnew_L;
H_R= hnew_L;

fdn = zeros(length(input),2);
tapout_sum = zeros(1,length(input));

% for n = 1 (first sample/no feedback)
% crossCouple_L = (H_L(1)*U(1,1)+H_R(1)*U(1,2)); %*gainAbsorbent;
% crossCouple_R = (H_L(1)*U(2,2)+H_R(1)*U(2,1)); %*gainAbsorbent;
%     
% for first feedback 
hN_L = inputDelayed(2) + H_L(2-1);
crossCouple_L = (H_L(2)*U(1,1)+H_R(2)*U(1,2));
hnew_L = [crossCouple_L  inputDelayed(1,1:length(input)-1)];

hN_R = inputDelayed(2) + H_R(2-1);
crossCouple_R = (H_L(2)*U(2,2)+H_R(2)*U(2,1));
hnew_R = [crossCouple_R  inputDelayed(1,1:length(input)-1)];


% feedback loop

for n = 1 : 7
    
    
for n = 3:length(input)

    %left
    hN_L = inputDelayed(n) + H_L(n-1) + hnew_L(n-1);
    crossCouple_L = (H_L(n)*U(1,1)+H_R(n)*U(1,2));
    hnew_L = [crossCouple_L  inputDelayed(1,1:length(input)-1)];
    
    [H_L,tapoutL] = lateReverb(hnew_L, lateDelaylines, gainAbsorbent,kn,attenuation);
    
    %----%
    %right
    hN_R = inputDelayed(n) + H_R(n-1) + hnew_R(n-1);
    crossCouple_R = (H_L(n)*U(2,2)+H_R(n)*U(2,1));
    hnew_R = [crossCouple_R inputDelayed(1,1:length(input)-1)];
    
    [H_R,tapoutR] = lateReverb(hnew_R, lateDelaylines, gainAbsorbent,kn,attenuation);
    
    %----%
    
%     crossCouple_L = (H_L(n)*U(1,1)+H_R(n)*U(1,2)); %*gainAbsorbent;
%     crossCouple_R = (H_L(n)*U(2,2)+H_R(n)*U(2,1)); %*gainAbsorbent;


end

%------------------------------------------------------------------------%
%%

close all
output = earlyRef*0.1 + H_L;
plot(output)
%------------------------------------------------------------------------%
%% Plotting
close all
load 'jungle.mat'

Ns = 2048; % number of points for fft
freq = (0:Ns-1)*(Fs/Ns); % scaling frequency range

sig_ref = jungle_L; % original sig
N = length(sig_ref); % sample length


sig_ref_fft = fft(sig_ref,Ns);
mag_ref = abs(sig_ref_fft);
mag_ref_db = 20*log10(mag_ref);


sig_fft = fft(output,Ns); % fft analysis
mag = abs(sig_fft);
mag_db = 20*log10(mag);

sig_fft_early = fft(earlyRef,Ns); % fft analysis
mag_early = abs(sig_fft_early);
mag_db_early = 20*log10(mag_early);

sig_fft_fdn = fft(fdn,Ns); % fft analysis
mag_fdn = abs(sig_fft_fdn);
mag_db_fdn = 20*log10(mag_fdn);




figure(2)
semilogx(freq,mag_ref_db)
axis([20 21000 -100 20])
hold on
semilogx(freq,mag_db)
axis([20 21000 -100 20])
grid on

figure(3)
semilogx(freq,mag_ref_db)
axis([20 21000 -100 20])
grid on

figure(4)
subplot(121)
semilogx(freq,mag_db)
axis([20 21000 -100 20])
grid on
 subplot(122)
plot(output)
grid on

figure(5)
subplot(121)
plot(sig_ref)
subplot(122)
plot(output)
grid on

