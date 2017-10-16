%% DRAFT FOR TEST
clear all
load 'jungle.mat'
Fs = 44100;
sig = jungle_L; % original sig

sig = jungle_L(258:end);

% Lowpass filter
% attenuation at high frequency
roomHighFreq = 3000;
LPF = Lowpass(sig,roomHighFreq,Fs);

%-----------------------------------------------------------------------------%
% Delay lines
% in samples

del = [661 970 1323 4410]; % tap delaylines values
c = [0.8 0.5 0.3 0.1];     % delay attenuation coefficients

Z = [];

for i = 1: 4
    y = c(i)*delay(LPF,del(i));
    Z(i,:) = [y]; % delay lines
end

% TDL
TDL = sum(Z)';

%-----------------------------------------------------------------------------%
%% Allpass filter

g = 0.4;
N = 2;
APF = Allpass(TDL,g,N);

%-----------------------------------------------------------------------------%
early_ref = APF*0.6;    % early reflections output

%-----------------------------------------------------------------------------%
%% FEEDBACK DELAY NETWORK
%-----------------------------------------------------------------------------%
% H(z) = N / (3 - Sum(g*Z(M)))

M = [457 1452 353];
g_M = 0.7;

FDN = filterbank(Z,3,M,g_M);



Mslength = [6615 14200]; %18036 28047 39469 53096 78189]; % absorbent allpass delay length
fc = 18000; % absorbent allpass cut-off frequency (HF reference value)

Diffusion  = 140;
maxallpass = 0.61803; % solution to 1−x^2 = x
g = maxallpass*(Diffusion/100); % All-Pass Coefficient

Tr = 2000; % decay time in ms
M_length = [150 321 409 635 894 1203 1772]; % delay lengths in ms
aDb = -60*(M_length/Tr);
att = 10.^(aDb/20); % Absorbent Gain

HFratio = 0.3;
dBGainFC = -60*(M_length/(HFratio*Tr));
G = 10.^(dBGainFC/20);

if G == 1
    b = 0;
else
    omega = cos(2*pi*fc/Fs);
    A = 8.*G - 4.*G.*G-9.*G.*omega + 4.*G.*G.*omega*omega;
    b = (2.*G.*omega - 2 + sqrt(A))/(2.*G-2);
end

apl = []; % initialize vector

for i = 1:1

    xdel = zeros(Mslength(i),1);  % delay with length M
    zero_endpad = zeros((Mslength(2)-Mslength(i)),1);
    Z = [xdel' sig' zero_endpad'];   % signal delayed

    [~,a] = butter(2,fc/(Fs/2)); % lowpass coefficients
    LPF = filter(b,a,Z); % lowpass filter

    zl = Mslength(2);
    zeros_pad = zeros(zl,1)';
    Sig_pad = [sig'  zeros_pad]; % resize input size to match the filtered signal

    y1 = g.*Sig_pad; % direct signal
    y2 = att(i).*LPF; % filtered signal
    y = y1+y2; % g.x(n) + filtered signal (delay+lowpass+att)

    fb = y*(-g); % feedback signal
    abf = [Sig_pad (y - fb)]; % absorbent allpass filter output

end
