%% Step 0: Get file
[s10, fs10] = getFile(10);
[s2, fs2] = getFile(2);
[s7, fs7] = getFile(7);
[s6, fs6] = getFile(6);
[s5, fs5] = getFile(5);
[s4, fs4] = getFile(4);

%% Codebook Generation Demo:
inputDic = train42(s2, fs2, "s2");
inputDic = train42(s4, fs4, "s4", inputDic);
inputDic = train42(s5, fs5, "s5", inputDic);
inputDic = train42(s6, fs6, "s6", inputDic);
inputDic = train42(s7, fs7, "s7", inputDic);
inputDic = train42(s10, fs10, "s10", inputDic);


%% Default Variables
[noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters;

%% Finding Optimal Number of Clusters (Distortion Method)
%close all
[noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters;
maxK = 96;
distortions = zeros(maxK, 1);

for K = 1:maxK
    label = strcat("s5, K = ", num2str(K));
    if (K==1)
        tryK = table;
    end
    tryK = train42(s5, fs5, label, tryK, false, ...
        true, N, p, pTrain, M, K, thres_distortion);
    distortions(K, 1) = tryK.distortion_cell{K, 1};
end

%figure
plot( (1:maxK)', distortions); hold on;
grid on
xlabel('Number of K-Cluster'); ylabel('Distortion Loss');
title(strcat('Threshold = ', ...
    num2str(thres_distortion) ) );

%% Finding Optimal Number of Clusters (Accuracy Method)
%close all
[noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters;
maxK = 64;
accKTrain = zeros(maxK, 1);
accKTest = zeros(maxK, 1);


for K = 1:maxK
    [accKTrain(K,1), accKTest(K,1)] = benchmark(numTrials, noise, N, p, ...
    pTrain, M, K, thres_distortion);
end

figure
plot( (1:maxK)', accKTrain); hold on;
plot( (1:maxK)', accKTest);
grid on
xlabel('Number of K-Cluster'); ylabel('Accuracy');
title("Accuracy Metrics" );
legend("Training Dataset (Cross-Validation)", "Test Dataset");

%% Finding Optimal Number of Windowing
[noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters;
maxN = 1024;
row = size(192:2:maxN, 1);
NAccTrain = zeros(row,1);
NAccTest = zeros(row,1);
nIdx = 1;
for N = 192:2:maxN
    M = round(N*2/3); % overlap length for stft()
    nDic = getInputDic(true, N, p, pTrain, M, K, thres_distortion);
    [NAccTrain(nIdx, 1), NAccTest(nIdx, 1)] = ...
        benchmark(numTrials, noise, N, p, pTrain, M, K, thres_distortion);
    nIdx = nIdx +1;
end

figure
plot(192:2:maxN, NAccTrain); hold on;
plot(192:2:maxN, NAccTest);
grid on
xlabel('Hamming Window Size'); ylabel('Accuracy');
title("Accuracy Metrics" );
legend("Training Dataset (Cross-Validation)", "Test Dataset");

%% Finding Optimal Number of Filter Banks
[noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters;
maxP = 45;
minP = 12;
% pTrain = 12;
pAccTrain = zeros(size(minP:maxP, 1),1);
pAccTest = zeros(size(minP:maxP, 1),1);
for p = minP:maxP
    pTrain = round(p*2/3); % Always get approx 66% of Filter Banks
    [pAccTest(p-(minP-1), 1), pAccTest(p-(minP-1), 1)] = ...
        benchmark(numTrials, noise, N, p, pTrain, M, K, thres_distortion);
end

figure
plot(minP:maxP, pAccTrain); hold on;
plot(minP:maxP, pAccTest);
grid on
xlabel('Number of Filter Banks'); ylabel('Accuracy');
title("Accuracy Metrics" );
legend("Training Dataset (Cross-Validation)", "Test Dataset");

%% Finding Optimal Number of MFCC-Coefficient (Accuracy Only)
[noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters;
p = 20;
maxPtrain = p;
row = size(2:maxPtrain, 1);
pTrainAccTrain = zeros(row,1);
pTrainAccTest = zeros(row,1);

for pTrain = 2:maxPtrain
    [pTrainAccTrain(pTrain-1, 1), pTrainAccTest(pTrain-1, 1)] = ...
        benchmark(numTrials, noise, N, p, pTrain, M, K, thres_distortion);
end

figure
plot(2:maxPtrain, pTrainAccTrain); hold on;
plot(2:maxPtrain, pTrainAccTest);
grid on
xlabel('Number of MFCC Used'); ylabel('Accuracy');

title("Accuracy Metrics" );
legend("Training Dataset (Cross-Validation)", "Test Dataset");

%% Finding Optimal Number of MFCC-Coefficient w/ Distortion Considerations
defaultParameters;
p = 20;
maxPtrain = p;
row = size(2:maxPtrain, 1);
pTrainAcc = zeros(row,1);
pTrainDistTest = zeros(row ,8); % row == 2:maxPtrain, col == 1:8 (Speaker_id)
pTrainDistTrain = zeros(row, 8);


for pTrain = 2:maxPtrain
    pDic = getInputDic(true, N, p, pTrain, M, K, thres_distortion);
    [pMat, pTrainAcc(pTrain-1, 1)] = getTestDic(pDic, rValid, N, p, pTrain, M);
    for spkr_id = 1:8
        pTrainDistTest(pTrain-1, spkr_id) = pMat(spkr_id, spkr_id);
        spkrTrain_Dist = pDic{spkr_id,2}{1,1};
        pTrainDistTrain(pTrain-1, spkr_id) = spkrTrain_Dist;
    end
end

figure
plot(2:maxPtrain, pTrainAcc); hold on;
grid on
xlabel('Number of MFCC Used'); ylabel('Accuracy');
title(strcat('Threshold = ', ...
    num2str(thres_distortion) ) );

figure
plot(2:maxPtrain, pTrainDistTest(1:maxPtrain-1, 5) ); hold on;
plot(2:maxPtrain, pTrainDistTrain(1:maxPtrain-1, 5) );
grid on
xlabel('Number of MFCC Used'); ylabel('Distortion');
legend("Test Distortion", "Training Distortion")

%% Calling Default Values
function [noise, rValid, N, p, pTrain, M, K, thres_distortion, numTrials] ...
    = defaultParameters
    noise = false; % Adding Noise for training
    rValid = 2; % (float>1) Ratio for Speaker Validation
    N = 200; % Number of elements in Hamming window for stft()
    p = 20; % Number of filters in the filter bank for melfb
    pTrain = 12; % Number of filters to train on (from 1:pTrain)
    M = round(N*2/3); % overlap length for stft()
    K = 16;  % Number of Clusters
    thres_distortion = 0.003; % Or 0.05
    numTrials = 25;
end

%% Creating Dictionary for Training Tuning
% function trainDic = getInputDic(noise, N, p, pTrain, M, K, thres_distortion)
% 
% % Get file
% [s10, fs10] = getFile(10);
% [s2, fs2] = getFile(2);
% [s7, fs7] = getFile(7);
% [s6, fs6] = getFile(6);
% [s5, fs5] = getFile(5);
% [s4, fs4] = getFile(4);
% 
% % Codebook Generation:
% trainDic = train42(s2, fs2, "s2", table, false, noise, N, p, pTrain, M, K, thres_distortion);
% trainDic = train42(s4, fs4, "s4", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
% trainDic = train42(s5, fs5, "s5", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
% trainDic = train42(s6, fs6, "s6", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
% trainDic = train42(s7, fs7, "s7", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
% trainDic = train42(s10, fs10, "s10", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
% end


%% Checking Accuracy and Tabulate Distortion Table
function [testMat, acc] = getTestDic(trainDic, rValid, N, p, pTrain, M)
% testMat: Row-> trainDic's Codebook, Col -> Sound File Test

%testMat = zeros(11, pTrain);
spkIdx = zeros(8, 1);

for i = 1:8
    [s, fs] = getFile(i, "test");
    %path = string(strcat("./Data/s", num2str(i), "pink.wav"));
    [~, ~, spkIdx(i, 1), testMat(i, :)] = test42(s, fs, trainDic, rValid, N, p, pTrain, M);
end

gtIdx = (1:8)';

% [s10, fs10] = getFile(10);
% [s2, fs2] = getFile(2);
% [s7, fs7] = getFile(7);
% [s6, fs6] = getFile(6);
% [s5, fs5] = getFile(5);
% [s4, fs4] = getFile(4);
% spkIdx = zeros(6,1);
% gtIdx = [2;4;5;6;7;10];
% 
% [name, spkIdx(1,1), distort2] = test42(s2, fs2, trainDic, N, p, pTrain, M);
% [name, spkIdx(2,1), distort4] = test42(s4, fs4, trainDic, N, p, pTrain, M);
% [name, spkIdx(3,1), distort5] = test42(s5, fs5, trainDic, N, p, pTrain, M);
% [name, spkIdx(4,1), distort6] = test42(s6, fs6, trainDic, N, p, pTrain, M);
% [name, spkIdx(5,1), distort7] = test42(s7, fs7, trainDic, N, p, pTrain, M);
% [name, spkIdx(6,1), distort10] = test42(s10, fs10, trainDic, N, p, pTrain, M);

acc = sum( (spkIdx==gtIdx) ) ./ size(spkIdx,1);
% testMat = [distort2; distort4; distort5; distort6; distort7; distort10];

end