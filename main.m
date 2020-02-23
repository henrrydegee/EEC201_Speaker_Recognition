clear; clc; close all;
% EEC201 Speaker Recognition Project
% [Insert Name Here]

%% Variables
N = 256; % Number of elements in Hamming window for stft()
p = 20; % Number of filters in the filter bank for melfb

M = round(N*2/3); % overlap length for stft()

%% MAIN

% Step 0: Get file
[s, fs] = getFile(10);

% Step 1: Take the stft of signal
[yst, ystf, ystt] = stft(s, fs, 'Window', hamming(N), 'OverlapLength', M);
% yst: mxn matrix amplitude output of stft
% ystf: mx1 frequency output corresponding to stft
% ystt: nx1 time output corresponding to stft

% plotSpec(ystt, ystf, db(abs(yst))); caxis([-40, max(db(yst(:)))]);
% xlim([min(ystt), max(ystt)]); ylim([min(ystf), max(ystf)]);

% Step 2: Get mel frequency filter bank
m = melfb(p, N, fs); % Mel-spaced filter bank

% figure; plot(linspace(0, (fs/2), 129), m');
% title('Mel-spaced filterbank'); xlabel('Frequency (Hz)');

% Step 3: Take the positive half of the frequency (since symmetry)
% and matrix multiply the mel filter bank with stft output
ystcut = yst(128:end, :);
ystcut = ystcut .* conj(ystcut); % take square
mfcstuff = m * ystcut; % matrix multiply mel with stft

% plotSpec(ystt, 1:p, db(abs(mfcstuff))); caxis([-40, max(db(mfcstuff(:)))]);
% xlim([min(ystt), max(ystt)]); ylim([0 p-1]);

% Step 4: Take the log10 of the matrix multiply output
% and apply dct
sk = log10(mfcstuff);
cn = dct(sk);

% Step 5: Plot the amplitude output of the dct
plotSpec(ystt, 1:p, cn); caxis([-30 15]);
xlim([min(ystt), max(ystt)]); ylim([1 p]);

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

function plotSpec(x, y, z)
    % Plots spectrogram (?)
    figure; surf(x, y, z,'EdgeColor','none'); view(0, 90); colorbar;
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