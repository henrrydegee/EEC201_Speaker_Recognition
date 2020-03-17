%% Benchmark
% Tests model against all train and test data
function [accTrain, accTest] = benchmark(numTrials, noise, N, p, ...
    pTrain, M, K, thres_distortion)

% Parameters
if ~exist('numTrials', 'var') || isempty(numTrials)
    numTrials =  10; % Number of times to iterate
end
rValid = 2;

% Declare Variables
failedTrain = 0; failedTest = 0;
trainFails = zeros(1, 11); testFails = zeros(1, 8);

% Main
for j = 1:numTrials
    % Train with all train data
    if nargin < 2
        inputDic = getInputDic();
    else
        inputDic = getInputDic(noise, N, p, pTrain, M, K, thres_distortion); 
    end

    % Test against train data
    for i = 1:11
        [s, fs] = getFile(i, "train");
        
        if nargin == 0 || nargin == 1
            outSpkr = test42(s, fs, inputDic);
        else
            outSpkr = test42(s, fs, inputDic, rValid, N, p, pTrain, M);
        end
        
        spkrRef = string(strcat("s", num2str(i)));
        if outSpkr ~= spkrRef
            % fprintf("Test %i (Train) Failed: out=%s\n", i, outSpkr);
            failedTrain = failedTrain + 1;
            trainFails(i) = trainFails(i) + 1;
        end
    end

    % Test against test data
    for i = 1:8
        [s, fs] = getFile(i, "test");
        
        if nargin == 0 || nargin == 1
            outSpkr = test42(s, fs, inputDic);
        else
            outSpkr = test42(s, fs, inputDic, rValid, N, p, pTrain, M);
        end
        
        spkrRef = string(strcat("s", num2str(i)));
        if outSpkr ~= spkrRef
            % fprintf("Test %i (Test) Failed: out=%s\n", i, outSpkr);
            failedTest = failedTest + 1;
            testFails(i) = testFails(i) + 1;
        end
    end
end

% Report Percentages
totalTrain = 11 * numTrials; totalTest = 8 * numTrials;
accTrain = (1-failedTrain/totalTrain);
accTest = (1-failedTest/totalTest);

fprintf("Against Train Data: Failed %i/%i, Acc=%.2f%%\n", failedTrain, ...
    totalTrain, accTrain*100);
fprintf("Against Test Data: Failed %i/%i, Acc=%.2f%%\n", failedTest, ...
    totalTest, accTest*100);

if any(trainFails)
    trainFails
end
if any(testFails)
    testFails
end

end