%% ------ JOT REVERBERATOR ------ %%
clear all; close all;
%%
%-----------------------------------------------------------------------------%
% Initialize variables
%-----------------------------------------------------------------------------%

load 'jungle.mat'

Fs = 44100;


sig = [1; zeros(3999,1)];
%[sig,fs] = audioread('flute_music.wav');
%sig = jungle_L; % original sig

Ns = 2048; % number of points for fft

sig_fft = fft(sig,Ns); % fft analysis
freq = (0:Ns-1)*(Fs/Ns); % scaling frequency range

mag = abs(sig_fft);
mag_db = 20*log10(mag);


Tr = 2000;  % decay time in ms
Diffusion  = 100;

%-----------------------------------------------------------------------------%
% Early Reflections
%-----------------------------------------------------------------------------%

% Lowpass filter
% attenuation at high frequency
roomHighFreq = 3000;
LPF = Lowpass(sig,roomHighFreq,Fs);

%-----------------------------------------------------------------------------%
% Delay lines
% in samples

delayline = [661 970 1323 4410]; % tap delaylines values
bn = [0.8 0.5 0.3 0.1];     % delay attenuation coefficients

Z = [];
maxldel = max(delayline);
bufflength = length(LPF)+maxldel;

for i = 1: 4
    y = delayZ(LPF,delayline(i),bn(i)); % delayline
    zpad = zeros(1,bufflength-length(y));
    y1 = [y zpad];
    Z(i,:) = [y1]; % store delaylines
end

% Tapped delay lines (y(n) = b0x(n)+bm1x(n-m1)+bm2x(n-m2)+bm3x(n-m3)
TDL = sum(Z)';

%-----------------------------------------------------------------------------%
% Allpass filter

gainAllpass = 0.4;
orderAllpass = 2;
APF = Allpass(TDL,gainAllpass,orderAllpass);

%-----------------------------------------------------------------------------%
early_ref = APF*0.6;    % early reflections output



%-----------------------------------------------------------------------------%
%% FEEDBACK DELAY NETWORK
%-----------------------------------------------------------------------------%

gainFDN = 0.6;
cn = [0.8 0.8 0.8 0.8];
d = 0.4;

gain = gainFDN/sqrt(2);
a = gain.*[0 1 1 0; -1 0 0 -1; 1 0 0 -1; 0 1 1 0]; % Feedback matrix

%A = [a -a -a -a; -a a -a -a; -a -a a -a; -a -a -a a];

sig = sig';



m = delayline;
gainAbsorbent = 0.5;
at = 0.9; % attenuation

%
M = [6615 14200 18036 28047 39469 53096 78189]; % absorbent allpass delay length
Tr = 2000;  % decay time in ms
Diffusion  = 100;
kn = [0.9 0.6 0.5 0.4 0.6 0.3 0.2];

%%
for i = 1:4 
    for j = 1:length(sig)
        h = APL(Z(i,j),M(i),kn(i),gainAbsorbent,at);
        H(i,j) = [h];
    end
end


%%
% filterbank



% Delaylines
z1 = Z(1,:);
z2 = Z(2,:);
z3 = Z(3,:);
z4 = Z(4,:);


for n = 1:length(sig)
    
    tmp = [z1(m(1)) z2(m(2)) z3(m(3)) z4(m(4))];
    
    fdn(n) = sig(n) + cn(1)*z1(m(1))+ cn(2)*z2(m(2)) ...
        + cn(3)*z3(m(3)) + cn(4)*z4(m(4));
    
    z1 = [(sig(n)*bn(1) + tmp*a(1,:)') z1(1:length(z1)-1)];
    z2 = [(sig(n)*bn(2) + tmp*a(2,:)') z2(1:length(z2)-1)];
    z3 = [(sig(n)*bn(3) + tmp*a(3,:)') z3(1:length(z3)-1)];
    z4 = [(sig(n)*bn(4) + tmp*a(4,:)') z4(1:length(z4)-1)];
    
end

% % Absorbent Delay Lines
% z1 = H(1,:);
% z2 = H(2,:);
% z3 = H(3,:);
% z4 = H(4,:);
% 
% for n = 1:length(sig)
%     
%     tmp = [z1(m(1)) z2(m(2)) z3(m(3))];
%     
%     fdn(n) = sig(n) + cn(1)*z1(m(1))+ cn(2)*z2(m(2)) ...
%         + cn(3)*z3(m(3));
%     
%     z1 = [(sig(n)*bn(1) + tmp*a(1,3)') z1(1:length(z1)-1)];
%     z2 = [(sig(n)*bn(2) + tmp*a(2,3)') z2(1:length(z2)-1)];
%     z3 = [(sig(n)*bn(3) + tmp*a(3,3)') z3(1:length(z3)-1)];
%     
% end

