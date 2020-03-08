clear; clc; close all;
% EEC201 Speaker Recognition Project
% Team 42
% Henrry Gunawan, Wai Cheong Tsoi

%% Parameters
N = 256; % Number of elements in Hamming window for stft()
p = 20; % Number of filters in the filter bank for melfb

M = round(N*2/3); % overlap length for stft()

%% MAIN

% Step 0: Get file
[s10, fs10] = getFile(10);
[s2, fs2] = getFile(2);

%plot(0:length(t)-1, abs(fft(s)))
%sound(s10, fs10)
%sound(cropZero(s2), fs2)
%sound(cropZero(s10), fs10)
%plotTime(s10, fs10)
plotTime(cropZero(s10), fs10);
plotTime(cropZero(s2), fs2);

%% Start MFCC
[cn10, ystt10] = mfcc(cropZero(s10), fs10, N, p, M);
[cn2, ystt2] = mfcc(cropZero(s2), fs2, N, p, M);

% Step 5: Plot the amplitude output of the dct
plotMFCC(ystt10, cn10, p, 10)
plotMFCC(ystt2, cn2, p, 2)

% 2xyz
[x1, y1, z1] = surfToXYZ(ystt2, (1:p)', cn2');
[x2, y2, z2] = surfToXYZ(ystt10, (1:p)', cn10');
figure; scatter3(x1, y1, z1, 'o');
hold on; scatter3(x2, y2, z2, 'x');
view(90, 0); xlabel('Time(s)'); ylabel('MFCC'); zlabel('Amplitude');

%% Recognizing Point Clusters through different axis

% Plotting Time vs Amplitude at a given mfc coefficient
% mfcc_id = 1;
% figure; plot(ystt2, cn2(mfcc_id,:)', 'x');
% xlabel('Time (s)'); ylabel('Amplitude');
% title(strcat( 'Speaker ID: ', int2str(2),...
%     ' w/ Coefficient: ', int2str(mfcc_id) ));

% Dynamically Plotting mfcc vs Amplitude through time
% figure;
% plot(1:p, cn2(:,1), 'x');
% hold on
% plot(1:p, cn10(:,1), 'o');
% for t = 2:length(ystt10)
%     hold off
%     plot(1:p, cn2(:,t), 'x');
%     hold on
%     plot(1:p, cn10(:,t), 'o');
%     xlabel('mfcc Coefficient'); ylabel('Amplitude');
%     ylim([-10, 10]);
%     legend('Speaker ID: 2', 'Speaker ID: 10');
%     pause(0.1); hold off
%     %title(strcat( 'Time: ', int2str(ystt2(t) ) ));
% end


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

function plotMFCC(ystt, cn, p, speaker_id)
    plotSpec(ystt, 1:p, cn); caxis([-30 15]);
    xlim([min(ystt), max(ystt)]); ylim([1 p]);
    xlabel('Time (s)'); ylabel('mfc coefficients');
    title(strcat('Speaker ID: ', int2str(speaker_id)) );
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
    cri = abs(s2) > db2mag(-30);
    y = s(find(cri, 1, 'first'):find(cri, 1, 'last')); % crop
end