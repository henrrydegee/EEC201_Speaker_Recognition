%% LBG Algorithm:
% Inspired by Run-TMC and Run-DMC
function [centroids, idx, curr_distortion] = runLBG(X, initial_centroids, ...
                                      thres_distortion, plot_progress)
%RUNKMEANS runs the K-Means algorithm on data matrix X, where each row of X
%is a single example
%   [centroids, idx] = RUNKMEANS(X, initial_centroids, max_iters, ...
%   plot_progress) runs the K-Means algorithm on data matrix X, where each 
%   row of X is a single example. It uses initial_centroids used as the
%   initial centroids. max_iters specifies the total number of interactions 
%   of K-Means to execute. plot_progress is a true/false flag that 
%   indicates if the function should also plot its progress as the 
%   learning happens. This is set to false by default. runkMeans returns 
%   centroids, a Kxn matrix of the computed centroids and idx, a m x 1 
%   vector of centroid assignments (i.e. each entry in range [1..K])
%

% Set default value for plot progress
if ~exist('plot_progress', 'var') || isempty(plot_progress)
    plot_progress = false;
end

% Plot the data if we are plotting progress
if plot_progress
    figure;
    hold on;
end

% Set default value for distortion threshold
if ~exist('thres_distortion', 'var') || isempty(thres_distortion)
    thres_distortion = 0.05;
end

% Initialization
K = size(initial_centroids, 1); % Number of Clusters
centroids = initial_centroids;
previous_centroids = centroids;
idx = zeros(size(X, 1), 1);

prev_distortion = 0;

% % Run K-Means
% max_iters = 100;
% for i=1:max_iters

% Run LBG Algorithm
while (1)
    
%     % Output progress for K-Means
%     fprintf('K-Means iteration %d/%d...\n', i, max_iters);
%     if exist('OCTAVE_VERSION')
%         fflush(stdout);
%     end
    
    fprintf("LBG still be runnin' ...\n");
    if exist('OCTAVE_VERSION')
        fflush(stdout);
    end

    % For each example in X, assign it to the closest centroid
    idx = findMyHood(X, centroids);
    
    % Optionally, plot progress here
    if plot_progress
        plotProgresskMeans(X, centroids, previous_centroids, idx, K, i);
        previous_centroids = centroids;
        fprintf('Press enter to continue.\n');
        pause(0.25);
    end
    
    % Given the memberships, compute new centroids
    centroids = GoToMyHood(X, centroids, idx, K);
    
    % LBG Algorithm :
    curr_distortion = ThisTheHouse(X, idx, centroids, K);
    compare_distortion = abs( (prev_distortion-curr_distortion) ...
        /curr_distortion);
    fprintf('My brudders are %d far away \n', curr_distortion);
    if ( compare_distortion < thres_distortion )
        fprintf("I'm home brudder :D \n");
        break
    end
    prev_distortion = curr_distortion;

end

% Hold off if we are plotting progress
if plot_progress
    hold off;
end

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

%% GoToMyHood() defintion
function centroids = GoToMyHood(X, prev_centroids, idx, K)
%GoToMyHood finds the new centroids' location by computing 
%the means of the data points assigned to each centroid.
%
%Inputs:
%   X - [m*n] matrix containing m-samples and n-number of features
%   idx - [m*1] matrix containing each centroid membership on m-samples
%   K - number of centroids
%Outputs:
%   centroids - [K*n] matrix containing K-number of centroids
%               on a n-dimensional space (feature space)


    % You need to return the following variables correctly.
    centroids = zeros(K, size(X, 2));

    for i = 1:K
        sel = find(idx == i); % where i ranges from 1 to K
%         if ( isempty(sel) )
%             centroids(i,:) = prev_centroids(i,:);
%             continue
%         end
        centroids(i,:) = mean(X(sel,:));
    end

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