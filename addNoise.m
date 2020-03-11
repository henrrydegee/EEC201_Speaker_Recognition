function sOutput = addNoise(sInput, typeNoise)
%addNoise() adds coloured noise into the input sound file
% Inputs:
% sInput - Sound array
% typeNoise = {'brown', 'pink', 'white'}
%
% Output:
% sOutput - Sound array with Added Noise

% Scale sample
sInput = ampScale(sInput, 0.5);

% Get noise
% typeNoise = 'brown'; % type of noise
samp = length(sInput); % number of samples / length
numChan = 1; % number of channels

% bounded output
if (typeNoise == "brown")
    bOut = false;
else
    bOut = true;
end
fNoise = dsp.ColoredNoise(typeNoise, samp, numChan, 'BoundedOutput', bOut);
noiseOut = fNoise(); % get noise from generator

if (typeNoise == "brown")
    noiseOut = 0.01 .* noiseOut;
elseif (typeNoise == "white")
    noiseOut = ampScale(noiseOut, 0.1);
else
    noiseOut = ampScale(noiseOut, 0.3);
end



% % Plot
% t = (0:length(s)-1)/Fs;
% figure; plot(t, s, t, noiseOut);

%sound(noiseOut, Fs)

% Add noise and play
sOutput = sInput + noiseOut;
% p = audioplayer(s, Fs);
% play(p);

end

% Function to scale signal
function y = ampScale(s, k)
    if nargin == 1
        k = 1/2;
    end
    k = k / max(abs(s)); % Gain Factor
    y = k * s; % Multiply
end