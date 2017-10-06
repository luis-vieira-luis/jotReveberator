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
        Buffer_size = 192001;
        CircularBuffer = zeros(Buffer_size,2);
        BufferIndex = 1;
        NSamples = 0;

        %----------------------------------------------
        % Define Feedback Matrix (householder, N=16)
        A4 =  0.5*[1 -1 -1 -1; -1 1 -1 -1; -1 -1 1 -1; -1 -1 -1 1];
        A_holder = [A4 -A4 -A4 -A4; -A4 A4 -A4 -A4; -A4 -A4 A4 -A4; -A4 -A4 -A4 A4]; % matrix of unitary gain

        Delayline = zeros(16,Buffer_size); % 16 Delay lines
        householder = A_holder*Delayline; % householder matrix

        %----------------------------------------------
        del = [661 970 1323 4410];


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
        %%%%%%%%%%%%% EARLY REFLECTIONS %%%%%%%%%%%%%%
        %----------------------------------------------
        function y = delay(in,del)
            % Early reflections function using the delay lines for
            % a time period lower than 33ms
            for i = 1:4
                h = dfilt.delay(del(i));
                y(i) = filter(h,in);
                H(i) = [y(i)];
            end
             H = H';
        end



        %----------------------------------------------
        function lpf = lowpass()
            % 2nd order lowpass filter with cutoff adjustable by the user
            % normalized for a range of [0 Fs/2]
            [b,a] = butter(2,decayHighRatio/(fs/2));
        end



        %----------------------------------------------
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
