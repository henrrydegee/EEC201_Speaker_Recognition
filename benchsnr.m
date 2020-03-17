%% Benchmark SNR
% Test acceptable SNR threshold for current model

clear; % Clear all variables

% Parameters
NUM_TRIALS = 25;
MIN_SNR = 15;
MAX_SNR = 30;

% Variables
x = MIN_SNR:MAX_SNR;
failedCases = zeros(1, MAX_SNR-MIN_SNR+1);

% Per trial, loop through speakers and add noise with certain snr
for j = 1:NUM_TRIALS
    inputDic = getInputDic(); % Train model for each new trial

    for nl = MIN_SNR:MAX_SNR
        fc = 0;
        for i = 1:11
            [s, fs] = getFile(i, "train"); % Get file
            san = addNoise(s, "white", nl); % Add noise
            outSpkr = test42(san, fs, inputDic); % Get test output
            spkrRef = string(strcat("s", num2str(i))); % Get Reference Output
            if outSpkr ~= spkrRef
                fc = fc + 1; % Calculate failed cases per snr
            end
        end
        failedCases(nl-MIN_SNR+1) = failedCases(nl-MIN_SNR+1) + fc; % Add failed cases
    end
end

% Get Accuracy
acc = (11 *NUM_TRIALS - failedCases) .* 100 ./ (11 * NUM_TRIALS);
xthres = min(x(acc>=95));

% Print Result
titleStr = string(strcat('Lowest SNR with no less than 95% Accuracy = ', ...
    num2str(xthres), ' dB'));
disp(titleStr);

% Plot
figure; plot(x, acc);
hold on; plot([xthres, xthres], [min(acc), max(acc)]); hold off;
xlabel('Signal-to-Noise Ratio (dB)'); ylabel('Accuracy (%)');
title(titleStr); ylim([min(acc), max(acc)]);