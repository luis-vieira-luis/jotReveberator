%------------------------------------------------------------------------%
% JOT REVERBERATOR
%------------------------------------------------------------------------%


clear all; 
close all;

%------------------------------------------------------------------------%
% INITIALIZE GLOBAL VARIABLES
%------------------------------------------------------------------------%

Fs = 44100; % sample frequency

input = [1, zeros(1,3999)]; % input signal
output = zeros(4000,1);     % output signal

roomHF = 5; %order of the filter
decayHF = 0.9999; % ratio of decay between high and low freq [0. : 1.]
hfReference = 18999; %frequency control in Hz

decayTime = 1; % between 0 - 1
reflLevel = 1; % between 0 - 1
reflDelay = 1; % scale the tap delays

revLevel = 0.3;
revDelay = 0;
% spreadRef = 30; % percentage of spread between early reflections

diffusion = 58; % echo density in percentage
density = 1;   % modal density

% direct input gain coefficient
Bn = 0.3;

%------------------------------------------------------------------------%
% EARLY REFLECTIONS
%------------------------------------------------------------------------%
% Initialize local variables

% Delaylines
tapdelays = reflDelay.*[41 53 79 149]'; % tap delaylines values (primes)
nTapdelay = length(tapdelays); % number of tap delays

% Delay attenuation coefficients
bn = reflLevel*[0.9 0.7 0.68 0.55];

%bn = reflLevel*[1 1 1 1];

%Allpass
allpassGain = 0.7;
allpassDelay = 200; % in samples

%------------------------------------------------------------------------%
% Lowpass air absorption
LPF = Lowpass(input,roomHF,hfReference,Fs);

%-----------------------------------------------------------------------------%
% Tapped delaylines
TDL = tdl(LPF,nTapdelay,bn,tapdelays);

%-----------------------------------------------------------------------------%
% Allpass filter
allpassReflection = Allpass(TDL,allpassGain,allpassDelay);

%------------------------------------------------------------------------%
% Early Reflections output
earlyRef = allpassReflection*0.6;

%%
%------------------------------------------------------------------------%
% FEEDBACK DELAY NETWORK
%------------------------------------------------------------------------%
% Initialize local variables

gainFDN = 0.9; % g < 1; editable value for unitary poles in the matrix
gFeedbackMatrix = gainFDN/sqrt(2);
% Feedback matrix
feedbackMatrix = gFeedbackMatrix.*[0 1 1 0; -1 0 0 -1; 1 0 0 -1; 0 1 1 0];


cn = revLevel*[0.9 0.82 0.795 0.643]; % late reverberation gain coefficient 
maxallpass = 0.61803;
gainAbsorbent = maxallpass*(diffusion/100); % g
attenuation = decayTime*0.9; % attenuation (att)


% lateDelaylines = [28047 39469 53096 78189]; %39469 53096 78189]; 
lateDelaylines = revDelay+density.*[600 734 785 821];
kn = decayHF*[0.99 0.95 0.89 0.77]; %0.6 0.3 0.2];

maxdel = max(lateDelaylines);
%------------------------------------------------------------------------%
% Define late reverberation signal using lateDelaylines

% reverbsignal = zeros(4,length(input)+maxdel);
% 
% for l = 1:4
%     
%     %reverbSignal = delayM(input,lateDelaylines(1,l),cn(1,l));
%     reverbSignal = delayM2(input,lateDelaylines(1,l),cn(1,l),maxdel);
%    
%     reverbsignal(l,:) = [reverbSignal];
% end

%------------------------------------------------------------------------%
% calculate absorbent allpass filters
for i = 1:length(lateDelaylines)

    abf = abAllpass(TDL,lateDelaylines(:,i),...
        gainAbsorbent,kn(:,i),attenuation);
    
    H(:,i) = [abf]';
end


%------------------------------------------------------------------------%
% Feedback matrix
for n = 1:length(input)

    tmp = diag(H(lateDelaylines(:),:))';

    fdn(n) = input(n) + cn*tmp';

    H = [(input(n)*Bn + tmp*feedbackMatrix'); H(1:length(H)-1,:)];

end

%------------------------------------------------------------------------%

output = (earlyRef*1.1 + fdn*0.1)*0.12;


%------------------------------------------------------------------------%
%Plotting
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



% figure(1)
% subplot(511)
% plot(output)
% subplot(512)
% semilogx(freq,mag_ref_db)
% axis([20 21000 -100 20])
% subplot(513)
% semilogx(freq,mag_db)
% axis([20 21000 -100 20])
% subplot(514)
% semilogx(freq,mag_db_early)
% axis([20 21000 -100 20])
% subplot(515)
% semilogx(freq,mag_db_fdn)
% axis([20 21000 -100 20])
% 
% grid on

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

