classdef AbsorbentAllpass
    
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
        
        function obj = AbsorbentAllpass(val)
            if nargin == 1
                if isnumeric(val)
                    obj.del = val;
                else
                    error('Value must be numeric')
                end
            end
        end
        
        function zpad = zeroPad(obj)
            zpad = zeros(1,[obj.del]);
        end
        
        function bcoeffs = bCoeff(obj)
            bcoeffs = [[obj.g] (-[obj.g])*[obj.k] zeroPad(obj) ([obj.att]-[obj.att]*[obj.k])];
        end
        
        function acoeffs = aCoeff(obj)
            acoeffs = [1 -[obj.k] zeroPad(obj) ([obj.g]*[obj.att]-[obj.g]*[obj.att]*[obj.k])];
        end
        
        function zTransform = H(obj)
            zTransform = dsp.IIRFilter('Numerator',bCoeff(obj), ...
                'Denominator',aCoeff(obj));
        end
    end
    
end
