function [centroids, idx, curr_distortion] = runLBG(X, initial_centroids, ...
                                      thres_distortion, plot_progress)
%% LBG Algorithm:
%   |- Inspired by Run-TMC and Run-DMC
%
%runLBG() performs the LBG Algorithm by performing k-Clustering
%iteratively until a variance/disortion threshold has been met.
%
%K-Clustering: A Vector Quantization Method by classifying m data
%points/observations into K clusters through the nearest mean.
%
% Assumptions:
% Euclidean Distance is used to calculate the Cluster's
% Varaiance/Distortion
%
% Input:
%   X - Input Data Points' Matrix (m*f)
%       |- m = Number of Observations/Data Points
%       |- n = Dimension Size of Observation / Number of Features
%   initial_centroids - Matrix (K*n) containing Centroid points
%       |- K = Number of Clusters to Partition
%       |- n = Dimension Size of Cluster Points
%   thres_distortion - Threshold quantified by how much variance
%       has been reduced between previous centroids and current centroids
%       |- Note: Default has been set to 0.05
%   plot_progress - (From Coursera) Live Demo of K-Clustering Algorithm
%
% Outputs:
%   centroids - [K*n] matrix containing K-number of centroids
%               on a n-dimensional space (feature space)
%   idx - [m*1] matrix containing each centroid membership on m-samples
%   curr_distortion - Total Variance of each centroid's distortion/variance

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
    
    %fprintf("LBG still be runnin' ...\n");
    if exist('OCTAVE_VERSION')
        fflush(stdout);
    end

    % For each example in X, assign it to the closest centroid
    idx = findMyHood(X, centroids);
    
    % Optionally, plot progress here
    if plot_progress
        plotProgresskMeans(X, centroids, previous_centroids, idx, K, i);
        previous_centroids = centroids;
        pause(0.25);
    end
    
    % Given the memberships, compute new centroids
    centroids = GoToMyHood(X, idx, K);
    
    % LBG Algorithm :
    curr_distortion = ThisTheHouse(X, idx, centroids);
    compare_distortion = abs( (prev_distortion-curr_distortion) ...
        /curr_distortion);
    %fprintf('My brudders are %d far away \n', curr_distortion);
    if ( compare_distortion < thres_distortion )
        %fprintf("I'm home brudder :D \n");
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
function centroids = GoToMyHood(X, idx, K)
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

%% Visualization Plotting Functions
function drawLine(p1, p2, varargin)
%DRAWLINE Draws a line from point p1 to point p2
%   DRAWLINE(p1, p2) Draws a line from point p1 to point p2 and holds the
%   current figure

plot([p1(1) p2(1)], [p1(2) p2(2)], varargin{:});

end

function plotDataPoints(X, idx, K)
%PLOTDATAPOINTS plots data points in X, coloring them so that those with the same
%index assignments in idx have the same color
%   PLOTDATAPOINTS(X, idx, K) plots data points in X, coloring them so that those 
%   with the same index assignments in idx have the same color

% Create palette
palette = hsv(K + 1);
colors = palette(idx, :);

% Plot the data
scatter(X(:,1), X(:,2), 15, colors);

end

function plotProgresskMeans(X, centroids, previous, idx, K, i)
%PLOTPROGRESSKMEANS is a helper function that displays the progress of 
%k-Means as it is running. It is intended for use only with 2D data.
%   PLOTPROGRESSKMEANS(X, centroids, previous, idx, K, i) plots the data
%   points with colors assigned to each centroid. With the previous
%   centroids, it also plots a line between the previous locations and
%   current locations of the centroids.
%

% Plot the examples
plotDataPoints(X, idx, K);

% Plot the centroids as black x's
plot(centroids(:,1), centroids(:,2), 'x', ...
     'MarkerEdgeColor','k', ...
     'MarkerSize', 10, 'LineWidth', 3);

% Plot the history of the centroids with lines
for j=1:size(centroids,1)
    drawLine(centroids(j, :), previous(j, :));
end

% Title
title(sprintf('Iteration number %d', i))

end