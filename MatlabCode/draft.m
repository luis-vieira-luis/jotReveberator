%% DRAFT FOR TEST
clear all
load 'jungle.mat'
Fs = 44100;
sig = jungle_L; % original sig
%%

M = 123;
fc = 4500;
xdel = zeros(M,1);  % delay with length M
Z = [xdel' sig'];   % signal delayed

[b,a] = butter(2,fc/(Fs/2));
LPF = filter(b,a,Z);
%%
g = 0.7;
att = 0.7;

zeros_pad = zeros(123,1);
Sig_pad = [sig'  zeros_pad'];
f_out = g.*Sig_pad' + att.*LPF';

