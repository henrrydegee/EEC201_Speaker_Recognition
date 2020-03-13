function [name, confident, spkIdx, distort_compare] = test42(sound, fs, ...
    inputDic, rValid, N, p, pTrain, M)
%test42 tries to recognize the speaker in the sound
%array given the inputDic of codebooks
%
%Inputs:
%   sound - Sound Input Array
%   fs - Sampling Frequency (in Hz)
%   inputDic - Table of previously saved codebooks
%
%Output:
%   name - (string) Name of the Speaker seen in inputDic
%   confident - Boolean (T/F) -> True: Valid Speaker
%   spkIdx - (int) Speaker Index at inputDic Table
%   distort_compare - (numSpkr*1) distance/distortion between
%       Input Sound Data and inputDic's centroids
%
%Inputs for Tuning Purposes (can be left blank for default):
% |  rValid - Error Deviation between best and second best
% |     predicted speaker (Refer to the Code for more details)
% |  N - Number of elements in Hamming window for stft()
% |  p - Number of filters in the filter bank for melfb
% |  pTrain - Number of filters to train on (from 1:pTrain)
% |  M - overlap length for stft() for more samples
%
%

%% Default Variables
if ~exist('rValid', 'var') || isempty(rValid)
    rValid = 0.2; % Error Deviation Tolerance to validate speaker
end
if ~exist('N', 'var') || isempty(N)
    N = 248; % Number of elements in Hamming window for stft()
end
if ~exist('p', 'var') || isempty(p)
    p = 20; % Number of filters in the filter bank for melfb
end
if ~exist('pTrain', 'var') || isempty(pTrain)
    pTrain = 13; % Number of filters to train on (from 1:pTrain)
end
if ~exist('M', 'var') || isempty(M)
    M = round(N*2/3); % overlap length for stft()
end


%% Preperation to compare with inputDic
X = prepareTheHood(sound, fs, N, p, pTrain, M, true, false);
distort_compare = zeros(size(inputDic,1), 1);

%% Computing all errors/distance for each codebook/centroid membership
for entre = 1:size(inputDic, 1)
    centroids = inputDic.centroids_cell{entre,1}; % Table -> Struct -> Array
    K = size(centroids, 1); % Number of clusters
    idx = findMyHood(X, centroids);
    distort_compare(entre, 1) = ThisTheHouse(X, idx, centroids);
end

%% Finding the speaker
distort_sorted = sort(distort_compare);
spkIdx = find(distort_compare == distort_sorted(1));
delta_distort = abs(distort_sorted(2) - distort_sorted(1));
if ( delta_distort ./ distort_sorted(1) < rValid)
    confident = false;
else
    confident = true;
end
%[dummy, spkIdx] = min(distort_compare);
name = inputDic(spkIdx, :).Properties.RowNames;
name = string(name); % Cast from cell to string

end


%% findMyHood() Definition
function idx = findMyHood(X, centroids)
%findMyHood returns the centroid memberships for every example
%
%Inputs:
%   X - [m*n] matrix containing m-samples and n-number of features
%   centroids - [K*n] matrix containing K-number of centroids
%               on a n-dimensional space (feature space)
%Outputs:
%   idx - [m*1] matrix containing each centroid membership on m-samples
%

    % Set K
    K = size(centroids, 1);
    idx = zeros(size(X,1), 1);
    distance = zeros(size(X, 1), K);

    for i = 1:K
        diff = bsxfun(@minus, X, centroids(i,:));
        distance(:, i) = sum(diff.^2, 2);
    end

    [dummy idx] = min(distance, [], 2);
%     % Alternatively:
%     for j = 1:size(X,1)
%        [dummy idx(j)] = min(distance(j, :));
%     end

end

%% ThisTheHouse() Defintion
function distortion = ThisTheHouse(X, idx, centroids)
%Computes the mean distortion (error) around the cluster assigned
%Inputs:
%   X - [m*n] input matrix containing m-samples and n-number of features
%   idx - [m*1] matrix containing each centroid membership on m-samples
%   centroids - [K*n] matrix containing K-number of centroids
%               on a n-dimensional space (feature space)
%Outputs:
%   distortion - the mean distance of each cluster's assigned data points

    distortion = 0;
    K = size(centroids, 1);
    for clster = 1:K
        sel = find(idx == clster);
        diff = bsxfun(@minus, X(sel, :), centroids(clster,:));
        distortion = distortion + sum(diff.^2, 'all');
    end
    distortion = distortion ./ size(X, 1);
end