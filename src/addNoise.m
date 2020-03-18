function [sOutput, noiseOut] = addNoise(sInput, typeNoise, idealSNR)
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
        idealSNR = 25; % 25dB from signal
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
    scale = db2mag(-1*idealSNR-10) * max(abs(sInput));
    noiseOut = ampScale(noiseOut, scale);

    % Add noise to output
    sOutput = sInput + noiseOut;
    
    % Warn if Signal-to-Noise Ratio is too low
    R = snr(sOutput, noiseOut);
    if R < SNR_WARN_THRESHOLD
        warning("addNoise() produced a signal that has an SNR = %.3fdB", R);
    end
end

% Function to scale signal
function y = ampScale(s, k)
    if nargin == 1
        k = 1/2;
    end
    k = k / max(abs(s)); % Gain Factor
    y = k * s; % Multiply
end