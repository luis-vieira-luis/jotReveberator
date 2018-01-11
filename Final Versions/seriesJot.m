% Series Implementation
Fs = 44100;
in = [1 zeros(1,Fs)];


outl = zeros(1,10000);
load 'jungle.mat'

%------------------------------------------------------------------------%
%% user interaction parameters

maxlength_rev = 1000; % max length of delay global

hfReference = 4000; % cutoff frequency for intial lowpass
roomHF = 4;
decayHF = 0.01; % ratio of attenuation at high frequencies

decayTime = 10000; % decay in milliseconds of the late reverberation at loW frequencies
reflLevel = 1; % scale level of reflections
reflDelay = 20; % scale reflections delay lenghts

revLevel = 1; % scale level of reverb
revDelay = 0; % controls the spread of the delays in the tail
spreadRef = 0; % percentage of spread between early reflections

diffusion = 100; % echo density; in percentage [0 100%];
density = 1;   % modal density - scales the delay in the tail
%------------------------------------------------------------------------%
%% prime values for delay lenghts

p = primes(maxlength_rev); % calculate primes
maxLength_reflections = maxlength_rev - (maxlength_rev/2)-1; % max delay length for early reflections

if maxLength_reflections > 4000
    maxLength_reflections = 4000;
end

%logical condition to calculate vector of early reflection delays
forEarlyRef = p < maxLength_reflections;
pEarlyRef = p(forEarlyRef); % matrix with prime values
idx_early = sort(randperm(length(pEarlyRef),4));
earlyReflections = pEarlyRef(idx_early);

%logical condition to calculate vector of late  delays
forLateDel = p > maxLength_reflections;
pLateDel = p(forLateDel); % matrix with prime values
idx_late = sort(randperm(length(pLateDel),7)); % matrix of indexes
lateReverberation = pLateDel(idx_late)+density;
%------------------------------------------------------------------------%
%% calculate spread of early reflections
spread = spreadRef/100;
if spread > 0.0
    for n = 2:4
        earlySpread = earlyReflections + round(spread*(earlyReflections(n) - earlyReflections(n-1)));
    end
else
    earlySpread = earlyReflections;
end

earlyReflections = earlySpread;
%------------------------------------------------------------------------%
%% tunable parameters
%------------------------------------------------------------------------%
% abosrbent allpass gain calculation
% brings the zeros inside the unit circle
% g value seems reasonable at 0.5

maxallpass = -0.61803;
g = maxallpass*(diffusion/100);

%------------------------------------------------------------------------%
% absorbent attenuation calculation
% attenuation values should be in the range of 0.7 and 0.9
l = (lateReverberation.*1000)/Fs; % delay in milliseconds
adB = (-60*l)./decayTime;
att = 10.^(adB./20);

%------------------------------------------------------------------------%
% k lowpass coefficient calculation
% closer to 0 is an allpass closer to 1 is lowpass
% k values should be between 0.45 and 0.75

dBGainFC = -60*l/(decayHF*decayTime);
G = 10.^(dBGainFC/20);

for i = 1:length(G)
    if G(i) == 1
        k = 0;
    else
        omega = cos(2*pi*hfReference/Fs);
        A = 8*G(i)-4*G(i)*G(i)-8*G(i)*omega+4*G(i)*G(i)*omega*omega;
        K = (2*G(i)*omega - 2+sqrt(A))/(2*G(i)-2);
    end

    k(i) = K;
end

%------------------------------------------------------------------------%
%% lowpass filter (initial) air absorption

[b,a] = butter(roomHF,hfReference/(Fs/2),'low');
lpfOut = dfilt.df1(b,a);
% lpfOut = filter(b,a,in);

%------------------------------------------------------------------------%
% delayed input

hdel = dfilt.delay(reflDelay);
hinit = dfilt.cascade(lpfOut,hdel);
delayedInput = filter(hinit,in);
%------------------------------------------------------------------------%
%% Early reflections

% number of tap delays
nTapdelay = length(earlyReflections);

% Delay attenuation coefficients
bn = 1*[0.9 0.7 0.68 0.55];

% Tapped delaylines
[b_early] = tdl(delayedInput,nTapdelay,bn,earlyReflections);
earlyh = dfilt.dffir(b_early);

% Allpass
allpassGain = -0.7;
allpassDelay = 10; % in samples
bAllpass=[allpassGain zeros(1,allpassDelay-1) 1];
aAllpass=[1 zeros(1,allpassDelay-1) -allpassGain];

% Allpass filter
allpassReflection = dfilt.df1t(bAllpass,aAllpass);
hcasEarly = dfilt.cascade(earlyh,allpassReflection);

earlyFilter = filter(hcasEarly,delayedInput);
%-------------------------------------------------------------------------%
%% Late reverberation

%------------------------------------------------------------------------%
% Delayed input to late reverberation

firstRevTap = dfilt.delay(lateReverberation(1)+revDelay);
delayedInputTail = filter(firstRevTap,in);


%------------------------------------------------------------------------%
% delay lenghts
M = lateReverberation;

%------------------------------------------------------------------------%

% absorbent allpass 1
zero_padding1 = zeros(1, M(1));
b1 = [g (g)*k(1) zero_padding1 (att(1)-att(1)*k(1))];
a1 = [1 -k(1) zero_padding1 (g*att(1)-g*att(1)*k(1))];

h1 = dfilt.df1t(b1,a1);
set(h1,'arithmetic','double');
h1.PersistentMemory = true;

% absorbent allpass 2
zero_padding2 = zeros(1, M(2));
b2 = [g (-g)*k(2) zero_padding2 (att(2)-att(2)*k(2))];
a2 = [1 -k(2) zero_padding2 (g*att(2)-g*att(2)*k(2))];

h2 = dfilt.df1t(b2,a2);
set(h2,'arithmetic','double');
h2.PersistentMemory = true;

% absorbent allpass 3
zero_padding3 = zeros(1, M(3));
b3 = [g (-g)*k(3) zero_padding3 (att(3)-att(3)*k(3))];
a3 = [1 -k(3) zero_padding3 (g*att(3)-g*att(3)*k(3))];

h3 = dfilt.df1t(b3,a3);
set(h3,'arithmetic','double');
h3.PersistentMemory = true;

% absorbent allpass 4
zero_padding4 = zeros(1, M(4));
b4 = [g (-g)*k(4) zero_padding4 (att(4)-att(4)*k(4))];
a4 = [1 -k(4) zero_padding4 (g*att(4)-g*att(4)*k(4))];

h4 = dfilt.df1t(b4,a4);
set(h4,'arithmetic','double');
h4.PersistentMemory = true;

% absorbent delay section
b5 = [0 0 att(5)-att(5)*k(5)];
a5 = [1 (-k(5)) 0];

h5 = dfilt.df1t(b5,a5);
set(h5,'arithmetic','double');
h5.PersistentMemory = true;

% absorbent allpass 5
zero_padding6 = zeros(1, M(6));
b6 = [g (-g)*k(6) zero_padding6 (att(6)-att(6)*k(6))];
a6 = [1 -k(6) zero_padding6 (g*att(6)-g*att(6)*k(6))];

h6 = dfilt.df1t(b6,a6);
set(h6,'arithmetic','double');
h6.PersistentMemory = true;

% absorbent allpass 6
zero_padding7 = zeros(1, M(7));
b7 = [g (-g)*k(7) zero_padding7 (att(7)-att(7)*k(7))];
a7 = [1 -k(7) zero_padding7 (g*att(7)-g*att(7)*k(7))];

h7 = dfilt.df1t(b7,a7);
set(h7,'arithmetic','double');
h7.PersistentMemory = true;

%------------------------------------------------------------------------%

close all

% cascade in biquad sections
hcas1 = dfilt.cascade(h1,h2);
hcas2 = dfilt.cascade(hcas1,h3);
hcas3 = dfilt.cascade(hcas2,h4);
hcas4 = dfilt.cascade(hcas3,h5);
hcas5 = dfilt.cascade(hcas4,h6);
hcas6 = dfilt.cascade(hcas5,h7);

%output

y7 = zeros(1,length(in));


% feedback matrix 

gainFDN = 0.9999; % g < 1; editable value for unitary poles in the matrix
gFeedbackMatrix = gainFDN/sqrt(2);
r = 0;
% unitary matrix
U = gFeedbackMatrix.*[sin(r) cos(r); -cos(r) sin(r)];

for i = 1:12

    in = delayedInputTail + y7;

    y1 = filter(h1,in);
    y2 = filter(hcas1,y1);
    y3 = filter(hcas2,y2);
    y4 = filter(hcas3,y3);
    y5 = filter(hcas4,y4);
    y6 = filter(hcas5,y5);
    y7 = filter(hcas6,y7);

    out = y1+y2+y3+y4+y5+y6+y7;

end

jotOut = [earlyFilter + out outl(1:length(outl)-length(in))];
plot(jotOut)


%------------------------------------------------------------------------%
