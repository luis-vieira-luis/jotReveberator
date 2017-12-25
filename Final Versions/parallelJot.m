% Parallel implementation

in = [1 zeros(1,3999)];
Fs = 44100;
%------------------------------------------------------------------------%

%% user interaction parameters

maxlength_rev = 100; % max length of delay global

hfReference = 1500; % cutoff frequency for intial lowpass
roomHF = 2; % filter order initial lowpass filter
decayHF = 2; % ratio of attenuation

decayTime = 10; % decay in milliseconds of the late reverberation at loW frequencies
reflLevel = 1; % scale level of reflections
reflDelay = 20; % scale reflections delay lenghts

revLevel = 1; % scale level of reverb
revDelay = 0; % controls the spread of the delays in the tail
spreadRef = 0; % percentage of spread between early reflections

diffusion = 20; % echo density; in percentage [0 100%];
density = 0;   % modal density - scales the delay in the tail
%------------------------------------------------------------------------%
%% prime calculation
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
idx_late = sort(randperm(length(pLateDel),4)); % matrix of indexes
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
%% late reverberation
lateM = lateReverberation;

% Combfilter calculation
for i = 1:length(lateM)
    comb = combLPF(g,k(i),lateM(i),in);
    H(:,i) = [comb];
end

%------------------------------------------------------------------------%
% Feedback matrix 
% (refer to Digital Delay Networks for designing artifical reverberators 
% J. Jot and a. Chaigne. AES 1991. pp.17)

gainFDN = -0.7; % g < 1; editable value for unitary poles in the matrix
gFeedbackMatrix = gainFDN/sqrt(2);
% Feedback matrix
feedbackMatrix = gFeedbackMatrix.*[0 1 1 0; -1 0 0 -1; 1 0 0 -1; 0 1 1 0];

% late reverberation gain coefficient 
cn = [0.9753 0.82 0.795 0.7234]; 

% late reverberation loop
for n = 1:length(in)
    %signal values corresponding to the delay lenghts
    tmp = diag(H(lateM(:),:))';
    % delay network output
    fdn(n) = in(n) + cn*tmp'; 
    % updated signal for next loop
    H = [(in(n) + tmp*feedbackMatrix'); H(1:length(H)-1,:)]; 
end



close all
plot(fdn)
%------------------------------------------------------------------------%
