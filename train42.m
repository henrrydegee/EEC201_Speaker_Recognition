function dataTable = train42(sound, fs, name, inputDic, ...
    plot_learning, noise, N, p, pTrain, M, K, thres_distortion)
%train42 intellectually finds the sound's codebook by
%using the LBG method despite the noise "42" likes to make. 
%42 then saves it to a table
%that only 42 or MATLAB can comprehend.
%
%Inputs:
%   sound - Sound Input Array
%   fs - Sampling Frequency (in Hz)
%   name - Name/Label of the Speaker
%   inputDic - Table of previously saved codebooks
%    |- Note: If left blank, 42 will create a new table by default
%
%Outputs:
%   dataTable - Updated table of saved codebooks
%
%Inputs for Tuning Purposes (can be left blank for default):
% |  plot_learning - Bool (T/F) T -> Show K-Clustering in Action
% |  noise - Add Noisy Datapoints to Dataset (for Training Purposes)
% |  N - Number of elements in Hamming window for stft()
% |  p - Number of filters in the filter bank for melfb
% |  pTrain - Number of filters to train on (from 1:pTrain)
% |  M - overlap length for stft() for more samples
% |  K - Number of Clusters
% |  thres_distortion - Threshold quantified by how much variance
% |     has been reduced between previous centroids and current centroids
% |
% |-Note: Please refer to code for its default values   
%
%   

%% Default Variables
if ~exist('plot_learning', 'var') || isempty(plot_learning)
    plot_learning = true;
end
if ~exist('noise', 'var') || isempty(noise)
    noise = false;
end
if ~exist('N', 'var') || isempty(N)
    N = 200; %256; % Number of elements in Hamming window for stft()
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
if ~exist('K', 'var') || isempty(K)
    K = 7;  % Number of Clusters
end
if ~exist('thres_distortion', 'var') || isempty(thres_distortion)
    thres_distortion = 0.03; % Or 0.05
end


%% Preperation for LBG Algo:
X = prepareTheHood(sound, fs, N, p, pTrain, M, true, noise);

%% LBG Algo:
initial_centroids = initiateTheHood(X, K);
[centroids, idx, distortion] = runLBG(X, initial_centroids, ...
    thres_distortion, plot_learning);

%% Save to Table
centroids_cell = {centroids};
distortion_cell = {distortion};
dataTable = table(centroids_cell, distortion_cell, 'RowNames', name);
if ~exist('inputDic', 'var') || isempty(inputDic)
    return
else
    dataTable = [inputDic; dataTable];
    return
end

end
