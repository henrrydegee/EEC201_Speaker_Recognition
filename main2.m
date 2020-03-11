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
    N = 200; % Number of elements in Hamming window for stft()
    p = 20; % Number of filters in the filter bank for melfb
    pTrain = 12; % Number of filters to train on (from 1:pTrain)
    M = round(N*2/3); % overlap length for stft()
    K = 7;  % Number of Clusters
    thres_distortion = 0.03; % Or 0.05

%% Finding Optimal Number of Clusters
%close all

maxK = 25;
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

%% Finding Optimal Number of Filter Banks
maxP = 35;
minP = 15;
pTrain = 12;
pAcc = zeros(size(minP:maxP, 1),1);
for p = minP:maxP
    pDic = getTrainDic(true, N, p, pTrain, M, K, thres_distortion);
    [pMat, pAcc(p-(minP-1), 1)] = getTestDic(pDic, N, p, pTrain, M);
end

figure
plot(minP:maxP, pAcc); hold on;
grid on
xlabel('Number of Filter Banks'); ylabel('Accuracy');
title(strcat('Threshold = ', ...
    num2str(thres_distortion) ) );

%% Finding Optimal Number of MFCC-Coefficient
p = 32;
maxPtrain = p;
pTrainAcc = zeros(size(2:maxPtrain, 1),1);
for pTrain = 2:maxPtrain
    pDic = getTrainDic(true, N, p, pTrain, M, K, thres_distortion);
    [pMat, pTrainAcc(pTrain-1, 1)] = getTestDic(pDic, N, p, pTrain, M);
end

figure
plot(2:maxPtrain, pTrainAcc); hold on;
grid on
xlabel('Number of MFCC Used'); ylabel('Accuracy');
title(strcat('Threshold = ', ...
    num2str(thres_distortion) ) );

%% Creating Dictionary for Training Tuning
function trainDic = getTrainDic(noise, N, p, pTrain, M, K, thres_distortion)

% Get file
[s10, fs10] = getFile(10);
[s2, fs2] = getFile(2);
[s7, fs7] = getFile(7);
[s6, fs6] = getFile(6);
[s5, fs5] = getFile(5);
[s4, fs4] = getFile(4);

% Codebook Generation:
trainDic = train42(s2, fs2, "s2", table, false, noise, N, p, pTrain, M, K, thres_distortion);
trainDic = train42(s4, fs4, "s4", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
trainDic = train42(s5, fs5, "s5", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
trainDic = train42(s6, fs6, "s6", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
trainDic = train42(s7, fs7, "s7", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
trainDic = train42(s10, fs10, "s10", trainDic, false, noise, N, p, pTrain, M, K, thres_distortion);
end

%% Checking Accuracy and Tabulate Distortion Table
function [testMat, acc] = getTestDic(trainDic, N, p, pTrain, M)
% testMat: Row-> trainDic's Codebook, Col -> Sound File Test

% Get file
[s10, fs10] = getFile(10);
[s2, fs2] = getFile(2);
[s7, fs7] = getFile(7);
[s6, fs6] = getFile(6);
[s5, fs5] = getFile(5);
[s4, fs4] = getFile(4);
spkIdx = zeros(6,1);
gtIdx = (1:6)';

[name, spkIdx(1,1), distort2] = test42(s2, fs2, trainDic, N, p, pTrain, M);
[name, spkIdx(2,1), distort4] = test42(s4, fs4, trainDic, N, p, pTrain, M);
[name, spkIdx(3,1), distort5] = test42(s5, fs5, trainDic, N, p, pTrain, M);
[name, spkIdx(4,1), distort6] = test42(s6, fs6, trainDic, N, p, pTrain, M);
[name, spkIdx(5,1), distort7] = test42(s7, fs7, trainDic, N, p, pTrain, M);
[name, spkIdx(6,1), distort10] = test42(s10, fs10, trainDic, N, p, pTrain, M);

acc = sum( (spkIdx==gtIdx) ) ./ size(spkIdx,1);
testMat = [distort2; distort4; distort5; distort6; distort7; distort10];

end