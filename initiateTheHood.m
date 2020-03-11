function centroids = initiateTheHood(X, K)
%initiateTheHood assigns K centroids into a randomly chosen
%data point found in X matrix
%
% Inputs:
%   X - [m*n] matrix containing m-samples and n-number of features
%   K - Number of Clusters
% Output:
%   centroids - [K*n] matrix containing K-number of centroids
%               on a n-dimensional space (feature space)


% Initialize the centroids to be random examples
% Randomly reorder the indices of examples
randidx = randperm(size(X, 1));
% Take the first K examples as centroids
centroids = X(randidx(1:K), :);

% for idx = 1:K
%     n = randi([0,1], 1, size(X, 2) );
%     centroids(idx, :) = (-1).^n;
% end
% =============================================================

end

