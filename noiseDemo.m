% Noise Demo
clear; close all;

% Get sample
[s, Fs] = getFile(10);
s = ampScale(s, 0.5);

% Get noise
typeNoise = 'white'; % type of noise
samp = length(s); % number of samples / length
numChan = 1; % number of channels
bOut = true; % bounded output
fNoise = dsp.ColoredNoise(typeNoise, samp, numChan, 'BoundedOutput', bOut);
noiseOut = fNoise(); % get noise from generator
noiseOut = ampScale(noiseOut, 0.2);

% Plot
t = (0:length(s)-1)/Fs;
figure; plot(t, s, t, noiseOut);

% Add noise and play
s = s + noiseOut;
p = audioplayer(s, Fs);
play(p);

% Function to scale signal
function y = ampScale(s, k)
    if nargin == 1
        k = 1/2;
    end
    k = k / max(abs(s)); % Gain Factor
    y = k * s; % Multiply
end