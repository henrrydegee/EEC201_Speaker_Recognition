function name = test42(sound, fs, inputDic)

% Variables
N = 200; % Number of elements in Hamming window for stft()
p = 20; % Number of filters in the filter bank for melfb

M = round(N*2/3); % overlap length for stft()

% Do MFCC
[cn, ystt] = mfcc(cropZero(sound), fs, N, p, M, true);
X = [cn(1:12,:)']; % Test sample
distort_compare = zeros(size(inputDic,1), 1);

% Computing all errors/distance for each codebook/centroid membership
for entre = 1:size(inputDic, 1)
    centroids = inputDic.centroids_cell{entre,1}; % Table -> Struct -> Array
    K = size(centroids, 1); % Number of clusters
    idx = findMyHood(X, centroids);
    distort_compare(entre, 1) = ThisTheHouse(X, idx, ...
        centroids, K);
end

% Finding the speaker
[dummy, spkIdx] = min(distort_compare);
name = inputDic(spkIdx, :).Properties.RowNames;

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
function distortion = ThisTheHouse(X, idx, centroids, K)
%Computes the mean distortion (error) around the cluster assigned
%Inputs:
%   X - [m*n] input matrix containing m-samples and n-number of features
%   idx - [m*1] matrix containing each centroid membership on m-samples
%   centroids - [K*n] matrix containing K-number of centroids
%               on a n-dimensional space (feature space)
%   K - number of centroids
%Outputs:
%   distortion - the mean distance of each cluster's assigned data points

    distortion = 0;
    for clster = 1:K
        sel = find(idx == clster);
        diff = bsxfun(@minus, X(sel, :), centroids(clster,:));
        distortion = distortion + sum(diff.^2, 'all');
    end
    distortion = distortion ./ size(X, 1);
end