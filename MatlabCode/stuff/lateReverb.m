function [outLate,tapout] = lateReverb(input,lateDelaylines,gainAbsorbent,kn,attenuation)
% Series of absorbent all-pass filters and absorbent delayline
% uses the functions : abAllpass and abDelay for each filter

abf1 = abAllpass(input,lateDelaylines(1),gainAbsorbent,kn(1),attenuation);
abf2 = abAllpass(abf1,lateDelaylines(2),gainAbsorbent,kn(2),attenuation);
abf3 = abAllpass(abf2,lateDelaylines(3),gainAbsorbent,kn(3),attenuation);
abf4 = abAllpass(abf3,lateDelaylines(4),gainAbsorbent,kn(4),attenuation);

abf5 = abDelay(abf4,lateDelaylines(5),kn(5),attenuation);

abf6 = abAllpass(abf5,lateDelaylines(6),gainAbsorbent,kn(6),attenuation);
abf7 = abAllpass(abf6,lateDelaylines(7),gainAbsorbent,kn(7),attenuation);

outLate = abf7;
tapout = abf1+abf2+abf3+abf4+abf6+abf7;
end
