clear; clc; close all;
% EEC201 Speaker Recognition Project
% Team 42
% Henrry Gunawan, Wai Cheong Tsoi

%% Parameters
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

%plotTime(cropZero(s10), fs10)
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

X2 = normCN2(1:12,:)';
X7 = normCN2(1:12,:)';
X10 = normCN10(1:12,:)';
%figure

figure
plot(cn2(6,:)', cn2(7,:)', 'x')
hold on
plot(cn10(6,:)', cn10(7,:)', 'o')
xlabel('mfcc-6'); ylabel('mfcc-7')


%% =================== Part 3: K-Means Clustering ======================
K = 3;%7;
initial_centroids = kMeansInitCentroids(X2, K);
thres_distortion = 0.03;

% Run K-Means algorithm. The 'true' at the end tells our function to plot
% the progress of K-Means
[centroids2, idx2, distortion2] = runLBG(X2, initial_centroids, ...
    thres_distortion, true);

initial_centroids = kMeansInitCentroids(X10, K);
[centroids10, idx10, distortion10] = runLBG(X10, initial_centroids, ...
    thres_distortion, true);

initial_centroids = kMeansInitCentroids(X7, K);
[centroids7, idx7, distortion7] = runLBG(X7, initial_centroids, ...
    thres_distortion, true);

%tScore = tPrime(centroids2, centroids10, distortion2, distortion10)
fprintf('\nK-Means Done.\n\n');

fprintf('Program paused. Press enter to continue.\n');
pause;

%% Finding Optimal Number of Clusters Value
% X2 = normCN2(1:20,:)';
% X10 = normCN10(1:20,:)';
% 
% maxK = 25;
% thres_distortion = 0.03;
% distortions = zeros(maxK, 1);
% for K = 1:maxK
%     initial_centroids = kMeansInitCentroids(X2, K);
%     [centroids, idx, distortion] = runLBG(X2, initial_centroids, ...
%     thres_distortion);
%     distortions(K, 1) = distortion;
% end
% 
% figure
% plot( (1:maxK)', distortions); hold on;
% grid on
% xlabel('Number of K-Cluster'); ylabel('Distortion Loss');
% title(strcat('Threshold = ', ...
%     num2str(thres_distortion) ) );

%% Finding Optimal Threshold
% max_thres = 0.05;
% K = 7;
% thres_distortion = (0.01:0.002:max_thres)';
% distortions = zeros(size(thres_distortion,1), 1);
% 
% for row = 1:size(thres_distortion,1)
%     initial_centroids = kMeansInitCentroids(X2, K);
%     [centroids, idx, distortion] = runLBG(X2, initial_centroids, ...
%     thres_distortion(row,1) );
%     distortions(row, 1) = distortion;
% end
% 
% figure
% plot( thres_distortion, distortions); hold on;
% grid on
% xlabel('Distortion Threshold'); ylabel('Distortion Loss');
% title(strcat('K = ', ...
%     num2str(K) ) );
% 

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

