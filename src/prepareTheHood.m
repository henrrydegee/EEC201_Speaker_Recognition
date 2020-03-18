function X = prepareTheHood(sound, fs, N, p, pTrain, ...
    M, normalize, noise)
%prepareTheHood() preprocess the sound file to be used for
%training/testing the codebook
%
%Inputs:
%   sound - Sound Input Array
%   fs - Sampling Frequency (in Hz)
%   N - Number of elements in Hamming window for stft()
%   p - Number of filters in the filter bank for melfb
%   pTrain - Number of filters to train/trained on (from 1:pTrain)
%   M - overlap length for stft() for more samples
%   normalize - boolean (T/F): T -> Normalize mfcc Amplitudes
%   noise - Add Noisy Datapoints to Dataset (for Training Purposes)
%
%Outputs:
%   X - Data Points' Matrix (m*pTrain)
%       |- m = Number of Observations/Data Points
%       |- pTrain = Dimension Size of Observation / Number of Features
%

%% Default Values
    if ~exist('normalize', 'var') || isempty(normalize)
        normalize = true;
    end
    if ~exist('noise', 'var') || isempty(noise)
        noise = false;
    end

%% Do MFCC & Other Preprocessing Techniques
    [cn, ystt] = mfcc(cropZero(sound), fs, N, p, M, normalize);

%% Adding Noise Data Option & Prepare Datapoints for Clustering
    if noise
        sPink = addNoise(cropZero(sound), 'pink');
        sBrown = addNoise(cropZero(sound), 'brown');
        sWhite = addNoise(cropZero(sound), 'white');

        [cnPink, ystt] = mfcc(sPink, fs, N, p, M, normalize);
        [cnBrown, ystt] = mfcc(sBrown, fs, N, p, M, normalize);
        [cnWhite, ystt] = mfcc(sWhite, fs, N, p, M, normalize);

        X = [cn(1:pTrain,:)'; cnPink(1:pTrain,:)'; ...
        cnBrown(1:pTrain,:)'; cnWhite(1:pTrain,:)'];

    else
        X = cn(1:pTrain,:)';
    end

end

%% CropZero() Definition
function y = cropZero(s)
    % Deletes the leading and ending zeros
    % Note: Also get rids of -30dB of Amplitude
    
    s2 = round(s, 3); % sensitivity 
    cri = abs(s2) > db2mag(-30);
    y = s(find(cri, 1, 'first'):find(cri, 1, 'last')); % crop
end