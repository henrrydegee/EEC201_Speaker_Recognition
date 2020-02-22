clear; clc; close all;
% EEC201 Speaker Recognition Project
% [Insert Name Here]

%% MAIN
% Steps:
% 1. stft()
% 2. map the powers to each mel freq: mult mel
% 3. take the logs of power at each mel: log(2)
% 4. take the dct: dct(3)
% 5. take the amplitude: abs(4)

[s, fs] = getFile(10);
N = 256; M = round(N*2/3);
figure; stft(s, fs, 'Window', hamming(N), 'OverlapLength', M);

% [col, row] = size(y);
% t = 1:row;
% x = 0:col-1;
% figure; surf(t,x,abs(y),'EdgeColor','none'); ylabel('Frequency');
% axis xy; axis tight; colormap(jet); view(0,90);

%figure; plot(linspace(0, (12500/2), 129), melfb(20, 256, 12500)');
%title('Mel-spaced filterbank'); xlabel('Frequency (Hz)');

%% Spectrum-related Functions
function y = STFT(s)
    % Return the Short-time Fourier Transform
    % DEPRECATED: JUST USE stft()
    % WARNING: WILL BE DELETED WHEN MERGE
    
    N = 256; % frame size
    M = round(N/3); % frame increment
    
    y = zeros(N, round(length(s)/M));
    for i = 1:round(length(s)/M)
        indx = i*M;
        y(:, i) = fft(indx:indx+N-1);
    end
end

%% File IO Functions
function [s, fs, t] = getFile(id)
    % Reads from ./Data to fetch the file
    id_str = string( strcat('./Data/s', int2str(id), '.wav') );
    [s, fs] = audioread(id_str);
    t = (0:length(s)-1) / fs;
    if min(size(s)) > 1
        s = s(:, 1); % If more channel, get only first
    end
end

%% Plot Functions
function plotTime(s, fs)
    % Plot the Signal vs Time graph
    t = (0:length(s)-1)/fs;
    figure; plot(t, s); xlim([min(t), max(t)]);
    xlabel('Time (s)'); ylabel('Amplitude'); title('Time Spectra');
end

function plotFreq(s, fs)
    % Plot the FFT vs Freq graph
    N = length(s);
    f = fs*(0:(N/2))/N;
    Xk = fft(s, N);
    Pk = abs( Xk(1:(floor(N/2)+1) ) );
    figure; plot(f, Pk);
    xlabel('Frequency (Hz)'); ylabel('Amplitude');
    title('Frequency Spectra');
end

%% Pre-Processing Functions
function y = ampNorm(s)
    % Normalizes the signal to max amp of 1
    k = 1 / max(abs(s)); % Gain Factor
    y = k * s; % Multiply
end

function y = cropZero(s)
    % Deletes the leading and ending zeros
    % TODO: tweak sensitivity, possibly calc dB
    
    s2 = round(s, 3); % sensitivity 
    cri = abs(s2) > 0;
    y = s(find(cri, 1, 'first'):find(cri, 1, 'last')); % crop
end