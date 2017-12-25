function delayOut = delayLine(in,z)

del = dsp.Delay(z);
delayOut = del(in);
