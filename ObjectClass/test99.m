% Series Implementation
% in = [1 zeros(1,3999)];
in = rand(1,4000)*2-1;
Fs = 44100;

out = zeros(1,26460);
load 'jungle.mat'

%------------------------------------------------------------------------%
%%
maxlength_rev = 3999; % max length of delay (tunable)
p = primes(maxlength_rev); % calculate primes

maxLength_reflections = 140; % max delay length for early reflections

%logical condition to calculate vector of early reflection delays
forEarlyRef = p < maxLength_reflections;
pEarlyRef = p(forEarlyRef); % matrix with prime values
idx_early = sort(randperm(length(pEarlyRef),4));
earlyReflections = pEarlyRef(idx_early);

%logical condition to calculate vector of late  delays
forLateDel = p > maxLength_reflections;
pLateDel = p(forLateDel); % matrix with prime values
idx_late = sort(randperm(length(pLateDel),7)); % matrix of indexes
lateReverberation = pLateDel(idx_late);

refDelay = 1;
revDelay = 1;

earlyReflections = refDelay.*earlyReflections;
lateReverberation = revDelay.*lateReverberation;
%%
%------------------------------------------------------------------------%
% abosrbent allpass gain calculation
% brings the zeros inside the unit circle
% g value seems reasonable at 0.5

diffusion = 10; % in percentage [0 100%];
maxallpass = 0.61803;
g = maxallpass*(diffusion/100);

%------------------------------------------------------------------------%
% absorbent attenuation calculation
% attenuation values should be in the range of 0.7 and 0.9
l = (lateReverberation.*1000)/Fs; % delay in milliseconds
Tr = 1200; % decay in milliseconds
adB = (-60*l)/Tr;
att = 10.^(adB/20);

%------------------------------------------------------------------------%
% k lowpass coefficient calculation
% closer to 0 is an allpass closer to 1 is lowpass
% k values should be between 0.45 and 0.75

Fc = 230; % tunable with HF Reference property
dBGainFC = -60*l/(Fc*Tr);
G = 10.^(dBGainFC/20);

for i = 1:length(G)
    if G(i) == 1
        k = 0;
    else
        omega = cos(2*pi*Fc/Fs);
        A = 8*G(i)-4*G(i)*G(i)-8*G(i)*omega+4*G(i)*G(i)*omega*omega;
        K = (2*G(i)*omega - 2+sqrt(A))/(2*G(i)-2);
    end

        k(i) = K;
end
%%
%------------------------------------------------------------------------%
filtertype = 'IIR';
RoomHF = 6;  % order of the filter
hfReference = 5e3; % cutoff frequency
Rp = 0.1;
Astop = 80;
LPF = dsp.LowpassFilter(...
    'SampleRate',Fs,...
    'FilterType',filtertype,...
    'DesignForMinimumOrder',false,...
    'FilterOrder',RoomHF,...
    'PassbandFrequency',hfReference,...
    'PassbandRipple',Rp,...
    'StopbandAttenuation',Astop);
%%
%------------------------------------------------------------------------%
% Early reflections

% number of tap delays
nTapdelay = length(earlyReflections);

% Delay attenuation coefficients
bn = 1*[0.9 0.7 0.68 0.55];

[b]=tdl(in,nTapdelay,bn,earlyReflections);
H_early = dsp.FIRFilter('Numerator',b);
%h_early = dfilt.df1(b,1);
%earlyRefOutput = filter(h_early,in);

% Tapped delaylines
TDL_early = tdl(in,nTapdelay,bn,earlyReflections);


% Allpass
allpassGain = 0.7;
allpassDelay = 10; % in samples

% Allpass filter
allpassReflection = Allpass(TDL_early,allpassGain,allpassDelay);

%%
%----------------------------------x--------------------------------------%
% Late reverberation

% delay lenghts
M = lateReverberation;

%------------------------------------------------------------------------%

% absorbent allpass 1
zero_padding1 = zeros(1, M(1));
b1 = [g (g)*k(1) zero_padding1 (att(1)-att(1)*k(1))];
a1 = [1 -k(1) zero_padding1 (g*att(1)-g*att(1)*k(1))];

h1 = dfilt.df1t(b1,a1);
h1.PersistentMemory = false;
set(h1,'arithmetic','double');
h1.PersistentMemory = false;

% absorbent allpass 2
zero_padding2 = zeros(1, M(2));
b2 = [g (-g)*k(2) zero_padding2 (att(2)-att(2)*k(2))];
a2 = [1 -k(2) zero_padding2 (g*att(2)-g*att(2)*k(2))];

h2 = dfilt.df1t(b2,a2);
set(h2,'arithmetic','double');
h2.PersistentMemory = false;

% absorbent allpass 3
zero_padding3 = zeros(1, M(3));
b3 = [g (-g)*k(3) zero_padding3 (att(3)-att(3)*k(3))];
a3 = [1 -k(3) zero_padding3 (g*att(3)-g*att(3)*k(3))];

h3 = dfilt.df1t(b3,a3);
set(h3,'arithmetic','double');
h3.PersistentMemory = false;

% absorbent allpass 4
zero_padding4 = zeros(1, M(4));
b4 = [g (-g)*k(4) zero_padding4 (att(4)-att(4)*k(4))];
a4 = [1 -k(4) zero_padding4 (g*att(4)-g*att(4)*k(4))];

h4 = dfilt.df1t(b4,a4);
set(h4,'arithmetic','double');
h4.PersistentMemory = false;

% absorbent delay section
zero_padding5 = zeros(1, M(5));
b5 = [0 0 (att(5)-att(5)*k(5))];
a5 = [1 (-k(5)) 0];

h5 = dfilt.df1t(b5,a5);
set(h5,'arithmetic','double');
h5.PersistentMemory = false;

% absorbent allpass 5
zero_padding6 = zeros(1, M(6));
b6 = [g (-g)*k(6) zero_padding6 (att(6)-att(6)*k(6))];
a6 = [1 -k(6) zero_padding6 (g*att(6)-g*att(6)*k(6))];

h6 = dfilt.df1t(b6,a6);
set(h6,'arithmetic','double');
h6.PersistentMemory = false;

% absorbent allpass 6
zero_padding7 = zeros(1, M(7));
b7 = [g (-g)*k(7) zero_padding7 (att(7)-att(7)*k(7))];
a7 = [1 -k(7) zero_padding7 (g*att(7)-g*att(7)*k(7))];

h7 = dfilt.df1t(b7,a7);
set(h7,'arithmetic','double');
h7.PersistentMemory = false;

%------------------------------------------------------------------------%

close all
hcas=dfilt.cascade(h1,h2,h3,h4,h5,h6,h7); % cascade filter
hcas.persistentmemory = false;

% cascade in biquad sections
hcas1 = dfilt.cascade(h1,h2); 
hcas2 = dfilt.cascade(hcas1,h3);
hcas3 = dfilt.cascade(hcas2,h4);
hcas4 = dfilt.cascade(hcas3,h5);
hcas5 = dfilt.cascade(hcas4,h6);
hcas6 = dfilt.cascade(hcas5,h7);

%output 
out = filter(h1,in)+filter(hcas1,in)+filter(hcas2,in)...
    +filter(hcas3,in)+filter(hcas4,in)+filter(hcas5,in)+filter(hcas6,in);

%------------------------------------------------------------------------%

y7 = zeros(1,4000);

for i = 1:8
in = in + y7;
y1 = filter(h1,in);
y2 = filter(hcas1,y1);
y3 = filter(hcas2,y2);
y4 = filter(hcas3,y3);
y5 = filter(hcas4,y4);
y6 = filter(hcas5,y5);
y7 = filter(hcas6,y7);

end



% plot(y)

%------------------------------------------------------------------------%

