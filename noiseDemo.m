% Noise Demo
clear; close all;

% Get sample
[s, fs] = getFile(10);

% Get noise
typeNoise = 'white'; % type of noise
dbNoise = -25; % dB from signal
[sn, noise] = addNoise(s, typeNoise, dbNoise);

% Plot
t = (0:length(s)-1)/fs;
figure; subplot(2, 1, 1); plot(t, s); subplot(2, 1, 2); plot(t, sn);

% Add noise and play
p = audioplayer(sn, fs);
play(p);

% Analyze SNR
R = snr(s, noise);
fprintf("SNR = %.3fdB\n", R);