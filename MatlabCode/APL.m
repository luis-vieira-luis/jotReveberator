function out = APL(M_length,Tr,HFratio,Diffusion,fc,Fs,in)
% absorbent allpass filter
% M_length : delay length in ms
% fc : cut-off frequency
% HFRatio : ratio of the decay time at high freq
% att : attenuation coefficient (associated with delay and LPF)
% g : feedback and feedforward coefficient

%------------------------------------------------------------------------%
% calculate coeff 'b'

maxallpass = 0.61803; % solution to 1−x^2 = x
g = maxallpass*(Diffusion/100); % All-Pass Coefficient

aDb = -60*(M_length/Tr); % attenuation for T60
att = 10.^(aDb/20); % Absorbent Gain

dBGainFC = -60*(M_length/(HFratio*Tr));
G = 10.^(dBGainFC/20); %


if G == 1.0
    B = 0.0;
else
    omega = cos(2*pi*(fc/Fs));
    A = 8*G - 4*G*G-9*G*omega + 4*G*G*omega*omega;
    B = (2*G*omega - 2 + sqrt(A))/(2*G-2);
end

%------------------------------------------------------------------------%
% creating filter

z_padding = zeros(1, (M_length-3));
b = [g -g*B z_padding (att-att*B)];
a = [1 -B  z_padding (-g*att-g*att*B)];
out = filter(b, a, in);


end
