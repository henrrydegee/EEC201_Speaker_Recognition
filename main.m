clear; clc; close all;
% EEC201 Speaker Recognition Project
% [Insert Name Here]

%% Variables
N = 200; % Number of elements in Hamming window for stft()
p = 20; % Number of filters in the filter bank for melfb

M = round(N*2/3); % overlap length for stft()

%% MAIN

% Step 0: Get file
[s10, fs10] = getFile(10);
[s2, fs2] = getFile(2);
[s7, fs7] = getFile(7);

%plot(0:length(t)-1, abs(fft(s)))
%sound(s10, fs10)
%sound(cropZero(s2), fs2)
%sound(cropZero(s10), fs10)
%plotTime(s10, fs10)

plotTime(cropZero(s10), fs10)
plotTime(cropZero(s2), fs2)

%% Start MFCC
[cn10, ystt10] = mfcc(cropZero(s10), fs10, N, p, M);
[cn2, ystt2] = mfcc(cropZero(s2), fs2, N, p, M);
[cn7, ystt7] = mfcc(cropZero(s7), fs7, N, p, M);

% % Step 5: Plot the amplitude output of the dct
% plotMFCC(ystt10, cn10./ max(max(abs(cn10))), p, 10)
% plotMFCC(ystt2, cn2 ./ max(max(abs(cn2))), p, 2)
% plotMFCC(ystt7, cn7 ./ max(max(abs(cn7))), p, 7)

%% Prepare for k-Clustering
normCN10 = cn10 ./ max(max(abs(cn10)));
normCN2 = cn2 ./ max(max(abs(cn2)));
normCN7 = cn7 ./ max(max(abs(cn7)));

K = 5;
X2 = normCN2(1:3,:)';
X10 = normCN10(1:3,:)';
%figure

figure
plot(cn2(1,:)', cn2(2,:)', 'x')
hold on
plot(cn10(1,:)', cn10(2,:)', 'o')
xlabel('mfcc-1'); ylabel('mfcc-2')


%% =================== Part 3: K-Means Clustering ======================

max_iters = 10;

initial_centroids = kMeansInitCentroids(X2, K);
thres_distortion = 0.05;

% Run K-Means algorithm. The 'true' at the end tells our function to plot
% the progress of K-Means
[centroids, idx] = runLBG(X2, initial_centroids, thres_distortion, true);

initial_centroids = kMeansInitCentroids(X10, K);
[centroids, idx] = runLBG(X10, initial_centroids, thres_distortion, true);
fprintf('\nK-Means Done.\n\n');

fprintf('Program paused. Press enter to continue.\n');
pause;

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
    t = (0:length(s)-1); %/fs;
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
    plotSpec(ystt, 1:p, cn); caxis([-1 1]);
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

%% Signal Generator
function xn = fseries(f1, f2, n, fs, step)
% Generates Fourier Series with given frequencies
% Input:
% f1 = Starting Frequency
% f2 = Ending Frequency
% n = Time Domain / Domain of Signal
% fs = Sampling Frequency
% step = Steps between the consecutive frequencies
% Output:
% xn = x[n] Fourier Series

    xn = 0;     % Initialization of x[n]
    for f = f1:step:f2    % Fourier Series frequency
        xn = xn + sin( 2.*pi.*f.* (n ./fs) ) ;%...
            %+ cos( 2.*pi.*f.* (n ./fs) );
        if ( f > 1)
            xn = xn * 100 ./ (f);
        end
    end
end

%% mfcc function
function [cn, ystt] = mfcc(s, fs, N, p, M)
% Calculates the Mel-Frequency Ceptstral Coefficients
% Inputs:
% s - Audio vector (assuming 1-channel/mono-channel)
% fs - Sampling Frequency
% N - Number of elements in Hamming window for stft()
% p - Number of filters in the filter bank for melfb
% M - overlap length for stft()
%
% Outputs:
% cn - Mel-Frequency Ceptstral Coefficients w/ size (p*length(ystt))
% ystt - Time-domain for STFT(Short-Time Fourier Transform)

% Step 1: Take the stft of signal
[yst, ystf, ystt] = stft(s, fs, 'Window', hamming(N), 'OverlapLength', M);
% yst: mxn matrix amplitude output of stft
% ystf: mx1 frequency output corresponding to stft
% ystt: nx1 time output corresponding to stft

% plotSpec(ystt, ystf, db(abs(yst))); caxis([-40, max(db(yst(:)))]);
% xlim([min(ystt), max(ystt)]); ylim([min(ystf), max(ystf)]);
% xlabel('Time (s)'); ylabel('Frequency (Hz)');

% Step 2: Get mel frequency filter bank
m = melfb(p, N, fs); % Mel-spaced filter bank

% figure; plot(linspace(0, (fs/2), 129), m');
% title('Mel-spaced filterbank'); xlabel('Frequency (Hz)');

% Step 3: Take the positive half of the frequency (since symmetry)
% and matrix multiply the mel filter bank with stft output
ystcut = yst((N/2):end, :);
ystcut = ystcut .* conj(ystcut); % take square
mfcstuff = m * ystcut; % matrix multiply mel with stft

% plotSpec(ystt, 1:p, db(abs(mfcstuff))); caxis([-40, max(db(mfcstuff(:)))]);
% xlim([min(ystt), max(ystt)]); ylim([0 p-1]);

% Step 4: Take the log10 of the matrix multiply output
% and apply dct (Discrete Cosine Transform)
sk = log10(mfcstuff);
cn = dct(sk);

% Step 5: Plot the amplitude output of the dct
%plotSpec(ystt, 1:p, cn); caxis([-30 15]);
%xlim([min(ystt), max(ystt)]); ylim([1 p]);
%xlabel('Time (s)'); ylabel('mfc coefficients')
end