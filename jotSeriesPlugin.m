classdef jotSeriesPlugin < audioPlugin
    
    properties
        
        hfReference = 18000; % cutoff frequency for intial lowpass
        roomHF = 2; % raitio of attenuation in initial lowpass filter
        decayHF = 2; % ratio of attenuation in absorbent filters
        
        decayTime = 1000; % decay in milliseconds of the late reverberation at loW frequencies
        reflLevel = 1; % scale level of reflections
        reflDelay = 20; % scale reflections delay lenghts
        
        revLevel = 1; % scale level of reverb
        revDelay = 0; % controls the spread of the delays in the tail
        spreadRef = 0; % percentage of spread between early reflections
        
        diffusion = 40; % echo density; in percentage [0 100%];
        density = 1;   % modal density - scales the delay in the tail
        
    end
    
    properties (Access = private)
        
        %-------------------------------------------------------------%
        % max length of delay global
        maxlength_rev = 230;
        
        % circular buffer
        CircularBuffer = zeros(Fs*2,2);
        BufferIndex = 1;
        NSamples = 0;
        frameSize = 256;
        samplePerFrame = 1024;
        
        % max value of feedback/feedforward gain
        maxallpass = -0.61803;
        
        %-------------------------------------------------------------%
        % Initial Lowpass and Delay
        hLowpassInit
        hDelayInit
        hCascadeInit % cascade of hLowpassInit and hDelayInit
        
        %-------------------------------------------------------------%
        % Early Reflection properties
        allpassGain = -0.7;
        allpassDelay = 10; % in samples
        
        bAllpass
        aAllpass
        
        hEarly % early cascading filter (tapped delay line and allpass)
        hcasEarly % early reflections cascading filters
        
        bn = 1*[0.9 0.7 0.68 0.55]; % Delay attenuation coefficients
        maxLength_reflections = 140; % max delay length for early reflections
        
        %-------------------------------------------------------------%
        
        % zeros for allpass sections
        zero_padding1 = zeros(1, lateReverberation(1));
        zero_padding2 = zeros(1, lateReverberation(2));
        zero_padding3 = zeros(1, lateReverberation(3));
        zero_padding4 = zeros(1, lateReverberation(4));
        zero_padding6 = zeros(1, lateReverberation(6));
        zero_padding7 = zeros(1, lateReverberation(7));
        
        %-------------------------------------------------------------%
        
        y7 = zeros(1,length(in));
        
    end
    
    properties (Constant)
        
        PluginInterface = audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            'PluginName','Jot Reverberator',...
            audioPluginParameter('density','DisplayName','Density','Mapping',{'lin',1,10}),...
            audioPluginParameter('diffusion','DisplayName','Diffusion','Mapping',{'lin',1,100}),...
            audioPluginParameter('reflDelay','DisplayName','Early Reflections','Mapping',{'lin',1,10}),...
            audioPluginParameter('reflLevel','DisplayName','Early Reflections Gain','Mapping',{'lin',1,100}),...
            audioPluginParameter('revDelay','DisplayName','Spread','Mapping',{'lin',1,100}),...
            audioPluginParameter('revLevel','DisplayName','Tail','Mapping',{'lin',1,100}),...
            audioPluginParameter('decayTime','DisplayName','Decay Time','Mapping',{'lin',1,100}),...
            audioPluginParameter('hfReference','DisplayName','Lowpass Cutoff Frequency','Mapping',{'lin',500,19999}),...
            audioPluginParameter('decayHF','DisplayName','Lowpass absorbent filter Cutoff Frequency','Mapping',{'lin',500,19999}),...
            audioPluginParameter('roomHF','DisplayName','High frequency attenuation','Mapping',{'lin',1,5}),...
            audioPluginParameter('maxDelaylength','DisplayName','Max Delay','Mapping',{'lin',500,1000}));
    end
    
    %---------------------------------------------------------------------%
    %---------------------------------------------------------------------%
    
    methods
        
        function jot = jotSeriesPlugin
            
            %-------------------------------------------------------------%
            % Calculation of prime values for delay lenghts
            
            p = primes(maxlength_rev); % calculate primes
            
            %logical condition to calculate vector of early reflection delays
            forEarlyRef = p < maxLength_reflections;
            pEarlyRef = p(forEarlyRef); % matrix with prime values
            idx_early = sort(randperm(length(pEarlyRef),4));
            earlyReflections = pEarlyRef(idx_early);
            
            %logical condition to calculate vector of late  delays
            forLateDel = p > maxLength_reflections;
            pLateDel = p(forLateDel); % matrix with prime values
            idx_late = sort(randperm(length(pLateDel),7)); % matrix of indexes
            lateReverberation = pLateDel(idx_late);
            
            earlyReflections = refDelay.*earlyReflections;
            lateReverberation = revDelay.*lateReverberation;
            
            %-------------------------------------------------------------%
            % calculate spread of early reflections
            spread = spreadRef/100;
            if spread > 0.0
                for n = 2:4
                    earlySpread = earlyReflections + round(spread*(earlyReflections(n) - earlyReflections(n-1)));
                end
            else
                earlySpread = earlyReflections;
            end
            
            earlyReflections = earlySpread;
            
            %-------------------------------------------------------------%
            % tunable parameters
            %-------------------------------------------------------------%
            % abosrbent allpass gain calculation
            % brings the zeros inside the unit circle
            % g value seems reasonable at 0.5
            
            g = maxallpass*(diffusion/100);
            
            %-------------------------------------------------------------%
            % absorbent attenuation calculation
            % attenuation values should be in the range of 0.7 and 0.9
            
            l = (lateReverberation.*1000)/Fs; % delay in milliseconds
            adB = (-60*l)./decayTime;
            att = 10.^(adB./20);
            
            %-------------------------------------------------------------%
            % k lowpass coefficient calculation
            % closer to 0 is an allpass closer to 1 is lowpass
            % k values should be between 0.45 and 0.75
            
            dBGainFC = -60*l/(decayHF*decayTime);
            G = 10.^(dBGainFC/20);
            
            k = zeros(length(G),1);
            
            for i = 1:length(G)
                if G(i) == 1
                    k = 0;
                else
                    omega = cos(2*pi*hfReference/Fs);
                    A = 8*G(i)-4*G(i)*G(i)-8*G(i)*omega+4*G(i)*G(i)*omega*omega;
                    K = (2*G(i)*omega - 2+sqrt(A))/(2*G(i)-2);
                end
                
                k(i) = K;
            end
            
            %-------------------------------------------------------------%
            % lowpass filter (initial) air absorption
            
            [b,a] = butter(roomHF,hfReference/(Fs/2),'low');
            jot.hLowpassInit = dfilt.df1(b,a);
            
            %-------------------------------------------------------------%
            % delayed input
            
            jot.hDelayInit = dfilt.delay(reflDelay);
            jot.hCascadeInit = dfilt.cascade(jot.hLowpassInit,hDelayInit);
            
            %-------------------------------------------------------------%
            % Early Reflections
            
            % number of tap delays
            nTapdelay = length(earlyReflections);
            
            % max delay length for early reflection
            maxd=max(earlyReflections);
            
            % Set the b and a coefficients of the transfer function depending on g and d.
            b_early=[1 zeros(1,maxd)];
            
            for i = 1:nTapdelay
                b_early = b_early + [zeros(1,earlyReflections(i)) bn(i) ...
                    zeros(1,maxd-earlyReflections(i))];
            end
            
            
            % Allpass coefficients
            jot.bAllpass=[allpassGain zeros(1,allpassDelay-1) 1];
            jot.aAllpass=[1 zeros(1,allpassDelay-1) -allpassGain];
            
            
            %-------------------------------------------------------------%
            % Late Reverberation
            
            % absorbent allpass 1
            b1 = [g (g)*k(1) zero_padding1 (att(1)-att(1)*k(1))];
            a1 = [1 -k(1) zero_padding1 (g*att(1)-g*att(1)*k(1))];
            
            h1 = dfilt.df1t(b1,a1);
            set(h1,'arithmetic','double');
            h1.PersistentMemory = true;
            
            % absorbent allpass 2
            b2 = [g (-g)*k(2) zero_padding2 (att(2)-att(2)*k(2))];
            a2 = [1 -k(2) zero_padding2 (g*att(2)-g*att(2)*k(2))];
            
            h2 = dfilt.df1t(b2,a2);
            set(h2,'arithmetic','double');
            h2.PersistentMemory = true;
            
            % absorbent allpass 3
            b3 = [g (-g)*k(3) zero_padding3 (att(3)-att(3)*k(3))];
            a3 = [1 -k(3) zero_padding3 (g*att(3)-g*att(3)*k(3))];
            
            h3 = dfilt.df1t(b3,a3);
            set(h3,'arithmetic','double');
            h3.PersistentMemory = true;
            
            % absorbent allpass 4
            b4 = [g (-g)*k(4) zero_padding4 (att(4)-att(4)*k(4))];
            a4 = [1 -k(4) zero_padding4 (g*att(4)-g*att(4)*k(4))];
            
            h4 = dfilt.df1t(b4,a4);
            set(h4,'arithmetic','double');
            h4.PersistentMemory = true;
            
            % absorbent delay section
            b5 = [0 0 att(5)-att(5)*k(5)];
            a5 = [1 (-k(5)) 0];
            
            h5 = dfilt.df1t(b5,a5);
            set(h5,'arithmetic','double');
            h5.PersistentMemory = true;
            
            % absorbent allpass 5
            b6 = [g (-g)*k(6) zero_padding6 (att(6)-att(6)*k(6))];
            a6 = [1 -k(6) zero_padding6 (g*att(6)-g*att(6)*k(6))];
            
            h6 = dfilt.df1t(b6,a6);
            set(h6,'arithmetic','double');
            h6.PersistentMemory = true;
            
            % absorbent allpass 6
            b7 = [g (-g)*k(7) zero_padding7 (att(7)-att(7)*k(7))];
            a7 = [1 -k(7) zero_padding7 (g*att(7)-g*att(7)*k(7))];
            
            h7 = dfilt.df1t(b7,a7);
            set(h7,'arithmetic','double');
            h7.PersistentMemory = true;
            
            %-------------------------------------------------------------%
            
        end
        
        %-----------------------------------------------------------------%
        
        function reset(jot)
            
            reset(jot.hLowpassInit)
            reset(jot.hDelayInit)
            reset(jot.hCascadeInit)
            
            reset(jot.h1)
            reset(jot.h2)
            reset(jot.h3)
            reset(jot.h4)
            reset(jot.h5)
            reset(jot.h6)
            reset(jot.h7)
            
        end
        %-----------------------------------------------------------------%
        
        function hcasEarly = earlyReflections(jot,~)
            
            
            
            
        end
        %-----------------------------------------------------------------%
        
        function out = lateReverberation(jot,in)
            
            
            
            
        end
        %-----------------------------------------------------------------%
        
        function out = reverb(jot,in)
            % feedback matrix (45º degrees feed)
            
            
            
        end
        %-----------------------------------------------------------------%
        
        function out = process(plugin,in)
            
            out = zeros(size(in));
            writeIndex = plugin.BufferIndex;
            readIndex = writeIndex - plugin.NSamples;
            % check if readIndex exceed bounds
            if readIndex <= 0
                readIndex = readIndex + Fs*2;
            end
            
            %---------------------%
            
            for i = 1:size(in,1)
                
                % Early reflections tap delay lines filter
                jot.hEarly = dfilt.dffir(jot.b_early);
                
                % Allpass filter
                allpassReflection = dfilt.df1t(jot.bAllpass,jot.aAllpass);
                
                % Cascading filters: init lpf+delay, tapped delays, allpass
                hcasEarly = dfilt.cascade(jot.hCascadeInit,jot.hEarly,allpassReflection);
                % cascade in biquad sections
                hcas1 = dfilt.cascade(jot.h1,jot.h2);
                hcas2 = dfilt.cascade(hcas1,jot.h3);
                hcas3 = dfilt.cascade(hcas2,jot.h4);
                hcas4 = dfilt.cascade(hcas3,jot.h5);
                hcas5 = dfilt.cascade(hcas4,jot.h6);
                hcas6 = dfilt.cascade(hcas5,jot.h7);
                
                %output
                for i = 1:12
                    
                    in = in + plugin.y7;
                    
                    y1 = filter(jot.h1,in);
                    y2 = filter(hcas1,y1);
                    y3 = filter(hcas2,y2);
                    y4 = filter(hcas3,y3);
                    y5 = filter(hcas4,y4);
                    y6 = filter(hcas5,y5);
                    plugin.y7 = filter(hcas6,plugin.y7);
                    
                    out = y1+y2+y3+y4+y5+y6+plugin.y7;
                    
                end
                
            end
            %---------------------%
            % update writeIndex
            writeIndex = writeIndex + 1;
            if writeIndex > Fs*2
                writeIndex = 1;
            end
            
            readIndex = readIndex + 1;
            if readIndex > Fs*2
                readIndex = 1;
            end
            
            
            
        end
        %-----------------------------------------------------------------%
        
        % set properties' values
        function set.hfReference(plugin, val)
            plugin.hfReference = val;
            
        end
        function set.roomHF(plugin, val)
            plugin.roomHF = val;
            
        end
        function set.decayHF(plugin, val)
            plugin.decayHF = val;
            
        end
        function set.decayTime(plugin, val)
            plugin.decayTime = val;
            
        end
        function set.reflLevel(plugin, val)
            plugin.reflLevel = val;
            
        end
        function set.reflDelay(plugin, val)
            plugin.reflDelay = val;
            
        end
        function set.revLevel(plugin, val)
            plugin.revLevel = val;
            
        end
        function set.revDelay(plugin, val)
            plugin.revlDelay = val;
            
        end
        function set.spreadRef(plugin, val)
            plugin.spreadRef = val;
            
        end
        function set.diffusion(plugin, val)
            plugin.diffusion = val;
            
        end
        function set.density(plugin, val)
            plugin.density = val;
            
        end
        
        
        
        
        
        
    end
    
end
