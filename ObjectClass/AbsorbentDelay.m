classdef AbsorbentDelay

    properties
        % delay lenght
        del
        % brings the zeros inside the unit circle
        g
        % closer to 0 is an allpass closer to 1 is lowpass
        k
        % attenuation factor
        att
    end

    methods

        function zpad = zeroPad(obj)
        zpad = zeros(1,[obj.del]);
        end

        function bcoeffs = bCoeff(obj)
        bcoeffs = [0 0 zeroPad(obj) ([obj.att]-[obj.att]*[obj.k])];
        end

        function acoeffs = aCoeff(obj)
        acoeffs = [1 (-[obj.k]) zeroPad(obj) 0];
        end

        function zTransform = H(obj)
        zTransform = dsp.IIRFilter('Numerator',bCoeff(obj),'Denominator',aCoeff(obj));
        end
    end

end

