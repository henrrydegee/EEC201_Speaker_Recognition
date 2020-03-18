%% Benchmark SNR
% Test acceptable SNR threshold for current model
% Adds white, pink and brown noises

clear; % Clear all variables

% Parameters
NUM_TRIALS = 10;
MIN_SNR = 15;
MAX_SNR = 30;

% Variables
x = MIN_SNR:MAX_SNR;
failedCases = zeros(3, MAX_SNR-MIN_SNR+1);
typeNoises = ["white", "pink", "brown"];

% Per trial, loop through speakers and add noise with certain snr
for j = 1:NUM_TRIALS
    inputDic = getInputDic(); % Train model for each new trial
    
    for k = 1:3
        for nl = MIN_SNR:MAX_SNR
            fc = 0;
            for i = 1:11
                [s, fs] = getFile(i, "train"); % Get file
                san = addNoise(s, typeNoises(k), nl); % Add noise
                [outSpkr, isValid] = test42(san, fs, inputDic); % Get test output
                spkrRef = string(strcat("s", num2str(i))); % Get Reference Output
                if outSpkr ~= spkrRef
                    fc = fc + 1; % Calculate failed cases per snr
                end
            end
            failedCases(k, nl-MIN_SNR+1) = failedCases(k, nl-MIN_SNR+1) + fc; % Add failed cases
        end
    end
end

% Get Accuracy
acc = (11 *NUM_TRIALS - failedCases) .* 100 ./ (11 * NUM_TRIALS);

% Plot
figure; plot(x, acc);
xlabel('Signal-to-Noise Ratio (dB)'); ylabel('Accuracy (%)');
title('Accuracy vs SNR'); ylim([80, 100]); grid on;
legend(typeNoises(1), typeNoises(2), typeNoises(3));