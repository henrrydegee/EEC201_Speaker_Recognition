function dataTable = train42(sound, fs, name, inputDic)
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

%% Variables
N = 200; % Number of elements in Hamming window for stft()
p = 20; % Number of filters in the filter bank for melfb

M = round(N*2/3); % overlap length for stft()

%% Other Possible Datasets to train on
sPink = addNoise(cropZero(sound), 'pink');
sBrown = addNoise(cropZero(sound), 'brown');
sWhite = addNoise(cropZero(sound), 'white');

%% Do MFCC
[cn, ystt] = mfcc(cropZero(sound), fs, N, p, M, true);

[cnPink, ystt] = mfcc(sPink, fs, N, p, M, true);
[cnBrown, ystt] = mfcc(sBrown, fs, N, p, M, true);
[cnWhite, ystt] = mfcc(sWhite, fs, N, p, M, true);


%normCN = cn ./ max(max(abs(cn)));
%X = normCN(1:12,:)';
%X = cn(1:20,:)';
X = [cn(1:12,:)'; cnPink(1:12,:)'; ...
    cnBrown(1:12,:)'; cnWhite(1:12,:)'];

%% LBG Algo:
K = 7;
thres_distortion = 0.03; % 0.05

initial_centroids = initiateTheHood(X, K);
[centroids, idx, distortion] = runLBG(X, initial_centroids, ...
    thres_distortion, true);

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
