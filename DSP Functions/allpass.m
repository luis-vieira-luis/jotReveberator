function outAllpass = allpass(in,allpassGain,allpassDelay)


%If the feedback gain is more than 1, set it to 0.7 .
if allpassGain>=1
   allpassGain=0.7;
end

%Set the b and a coefficients of the transfer function depending on g and d.
b=[allpassGain zeros(1,allpassDelay-1) 1];
a=[1 zeros(1,allpassDelay-1) allpassGain];

coeffs = [b;a];

Allpass = dsp.AllpassFilter('AllpassCoefficients',coeffs,...
    'TrailingFirstOrderSection',true);

outAllpass = Allpass(in); 
