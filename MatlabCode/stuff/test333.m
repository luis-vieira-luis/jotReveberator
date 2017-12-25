clear all 
close all

in1 = [1; zeros(1000,1)]';
in2 = [1; zeros(1000,1)]';

%delay
del = [238, 547];
ydel_L = delayM2(in1,del(1),1);

ydel_R = delayM2(in2,del(2),1);

%allpass 
g = [0.5 0.5 0.5 0.5];
del_ap = [33 25 41 145];
% left channel
yap1 = Allpass(ydel_L,g(1),del_ap(1));
yap2 = Allpass(yap1,g(3),del_ap(3));
% right channel
yap3 = Allpass(ydel_R,g(2),del_ap(2));
yap4 = Allpass(yap3,g(4),del_ap(4));

%unitary matrix
r = 45;
U = [sin(r) cos(r); -cos(r) sin(r)];

gain = 0.9/sqrt(2);

% UFDN

%init feedback delay network array
fdn = zeros(length(in1),2);

for n = 1:length(in1)

if n == 1
    crossCouple_L = (yap2(n)*U(1,1)+yap4(n)*U(1,2))*gain;
    crossCouple_R = (yap2(n)*U(2,2)+yap4(n)*U(2,1))*gain;
    
end

if n >= 2
    
    hN_L = in1(n) + crossCouple_L;
    hnew_L = [hN_L  in1(1,1:length(in1)-1)];
    
    ydel_L = delayM2(hnew_L,del(1),0.4);
    yap1 = Allpass(ydel_L,g(1),del_ap(1));
    yap2 = Allpass(yap1,g(3),del_ap(3));
    
    crossCouple_L = (yap2(n)*U(1,1)+yap4(n)*U(1,2))*gain;
    
    %----%
    
    hN_R = in2(n) + crossCouple_R;
    hnew_R = [hN_R in2(1,1:length(in2)-1)];
    
    ydel_R = delayM2(hnew_R,del(2),0.7);
    yap3 = Allpass(ydel_R,g(2),del_ap(2));
    yap4 = Allpass(yap3,g(4),del_ap(4));
    
    crossCouple_R = (yap2(n)*U(2,2)+yap4(n)*U(2,1))*gain;

end

fdn(n,:) = [crossCouple_L, crossCouple_R];

end

figure
subplot(131)
plot(fdn)
title('fdn')
subplot(132)
plot(yap2)
title('channel L')
subplot(133)
plot(yap4)
title('channel R')

