function [sOutput, noiseOut] = addNoise(sInput, typeNoise, dbNoise)
    %addNoise() adds coloured noise into the input sound file
    % Inputs:
    % sInput - Sound array
    % dbNoise - dB of noise added from amplitude of sound
    % typeNoise = {'brown', 'pink', 'white'}
    %
    % Output:
    % sOutput - Sound array with Added Noise
    % noiseOut - The Noise added to the output

    SNR_WARN_THRESHOLD = 10; %dB

    % Set defaults
    if nargin < 3
        dbNoise = -20; % -20dB from signal
    end
    if nargin < 2
        typeNoise = "white";
    end

    % Set param
    samp = length(sInput); % number of samples / length
    numChan = 1; % number of channels
    bOut = (typeNoise ~= "brown");

    % Get Noise
    fNoise = dsp.ColoredNoise(typeNoise, samp, numChan, 'BoundedOutput', bOut);
    noiseOut = fNoise(); % get noise from generator

    % Scale to specified dB
    scale = db2mag(dbNoise) * max(abs(sInput));
    noiseOut = ampScale(noiseOut, scale);
    
    % Warn if Signal-to-Noise Ratio is too low
    R = snr(sInput, noiseOut);
    if R < SNR_WARN_THRESHOLD
        warning("addNoise() produced a signal that has an SNR = %.3fdB", R);
    end

    % Add noise to output
    sOutput = sInput + noiseOut;
end

% Function to scale signal
function y = ampScale(s, k)
    if nargin == 1
        k = 1/2;
    end
    k = k / max(abs(s)); % Gain Factor
    y = k * s; % Multiply
end