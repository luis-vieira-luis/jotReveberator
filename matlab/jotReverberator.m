classdef jotReverberator < audioPlugin

    properties
        % adjust the intensity level (Gain)
        roomGain = 0.5
        % adjust low-pass filter at the input to the reverberator (Hz)
        roomHighFreq = 18000
        % adjust the attenuations in each absorbent all-pass
        % and associated with each delay (Gain)
        decayTime = 0.5
        % adjust the coefficients of the low-pass filters
        % in each absorbent all-pass filter and associated with each delay
        % adjust poles value in the unity circle
        decayHighRatio = 8000
        % intensity level of the early reflections.
        reflectLevel = 0.5
        % move the early reflection taps
        reflectDelay = 1
        % intensity level of the late reverberation response.
        revLevel = 0.5
        % adjusts the time between the first early reflection
        % and the onset of the late reverberation response
        % by moving the tap that feeds the late reverb.
        revDelay = 1
        % adjusting the feedback coefficient g of each absorbent all-pass filter
        % lowest echo density is obtained for g = 0,
        % while the highest echo density is obtained for g ≈ 0.6.
        diffusion = 0.4
        % scaling the length of the delay lines in the absorbent all-pass filters
        density = 3
        % sets the frequency at which the Room High Frequency Level
        % and Decay High Frequency Ratio parameters are controlled
        highRef = 15000
    end
    %----------------------------------------------------------------------------------------------------------
    properties (Access = private)


        %----------------------------------------------
        % Define the size of the circular buffer
        Buffer_size = 192001;                   % buffer size
        CircularBuffer = zeros(Buffer_size,2);  % zero pad circular buffer
        BufferIndex = 1;                        % buffer index
        NSamples = 0;

        Fs = 44100;                             % sample frequency

        %----------------------------------------------
        % Define Feedback Matrix (householder, N=16)
        A4 =  0.5*[1 -1 -1 -1; -1 1 -1 -1; -1 -1 1 -1; -1 -1 -1 1];
        A_holder = [A4 -A4 -A4 -A4; -A4 A4 -A4 -A4; -A4 -A4 A4 -A4; -A4 -A4 -A4 A4]; % matrix of unitary gain

        Delayline = zeros(16,Buffer_size);      % 16 Delay lines
        householder = A_holder*Delayline;       % householder matrix

        %----------------------------------------------
        del = [661 970 1323 4410];              % init delay lines for early reflections taps
        g = []                                  % init gain for early reflections taps


    end
    %----------------------------------------------------------------------------------------------------------
    properties (Constant)

        PluginInterface = audioPluginInterface(...
        audioPluginParameter('roomGain','DisplayName','Label','%','Room Level','Mapping',{'lin',0,1}),...
        audioPluginParameter('roomHighFreq','DisplayName','Label','Hz','Room high Freq Level','Mapping',{'int',13000,19500}),...
        audioPluginParameter('decayTime','DisplayName','Label','%','Decay Time','Mapping',{'lin',0,1}),...
        audioPluginParameter('decayHighRatio','DisplayName','Label','Hz','Decay High Freq Ratio','Mapping',{'lin',1300,19500}),...
        audioPluginParameter('reflectLevel','DisplayName','Label','%','Reflections Level','Mapping',{'lin',0,1}),...
        audioPluginParameter('reflectDelay','DisplayName','Label','%','Reflections Delay','Mapping',{'int',1,3}),...
        audioPluginParameter('revLevel','DisplayName','Label','%','Reverb level','Mapping',{'lin',0,1}),...
        audioPluginParameter('revDelay','DisplayName','Label','%','Reverb Delay','Mapping',{'int',1,3}),...
        audioPluginParameter('diffusion','DisplayName','Label','%','Diffusion','Mapping',{'lin',0,0.6}),...
        audioPluginParameter('density','DisplayName','Label','%','Density','Mapping',{'lin',0,10}),...
        audioPluginParameter('highRef','DisplayName','Label','%','High Freq Reference','Mapping',{'lin',0,1}))

    end
    %----------------------------------------------------------------------------------------------------------
    methods
        function out = process(plugin,in)

            out = zeros(size(in));
            writeIndex = plugin.BufferIndex;
            readIndex = writeIndex - plugin.NSamples;
            if readIndex <= 0
               readIndex = readIndex + Buffer_size;
            end
            end

            %----------------------------------------------
            %%%%%%%%%%%% Early Reflections %%%%%%%%%%%%%%%%

            for i = 1:size(in,1)
                plugin.CircularBuffer(writeIndex,:) = in(i,:);

                % Lowpass filter at the input of the reverberator
                lpf_in = plugin.lpf(in,decayHighRatio,Fs)

                % init delaylines tap for early reflection and compute them
                % input signal is the lowpass filtered signal
                H = [];
                for i = 1:4
                    z(i) = plugin.z(lpf_in,del(i));
                    H(i) = [z(i)];
                end

                % Sum and add attenuator to all the delay lines
                Z = z(1)*0.9+z(2)*0.6+z(3)*0.4+z(4)*0.2;

                % Signal goes through an allpass filter
                early_ref = plugin.apf(Z,g,N)*apf_g;


                out(i,:) = in(i,:) + echo * plugin.Gain;

                writeIndex = writeIndex + 1;
                if writeIndex > 192001
                    writeIndex = 1;
                end

                readIndex = readIndex + 1;
                if readIndex > 192001
                    readIndex = 1;
                end
            end


            end










            %----------------------------------------------





        %----------------------------------------------
        function lpf = lowpass(in,decayHighRatio,fs)
            % 2nd order lowpass filter with cutoff adjustable by the user
            % normalized for a range of [0 Fs/2]
            [b,a] = butter(2,decayHighRatio/(fs/2));
            LPF = filter(b,a,in);
        end

        %----------------------------------------------
        function z = delay(in,del)
            % Early reflections function using the delay lines for
            % a time period lower than 33ms
                h = dfilt.delay(del);
                y = filter(h,in);
            end

        end

        %----------------------------------------------
        function apf = Allpass(in,g,N )
            z_padding = zeros(1, N-1);
            b = [-1 z_padding (1+g)];
            a = [1 z_padding -g];
            APF = filter(b, a, in);
        end








        %---------------------------------------------%
        %---------------------------------------------%
        function reset(~)
            % This section contains instructions to reset the plugin
            % between uses, or when the environment sample rate changes.


        end
        function set.MyProperty(~, ~)
            % This section contains instructions to execute if the
            % specified property is modified. Properties associated with
            % parameters are updated automatically. Use the set method to
            % execute more complicated instructions.
        end

    end
end
