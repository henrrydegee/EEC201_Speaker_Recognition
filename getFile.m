function [s, fs, t] = getFile(id)
%Reads from ./Data to fetch the file
% Input:
% id = {0,1,2,..,10,11}
%
% Outputs:
% s - Sound array containing amplitudes
% fs - Sampling Frequency (in Hz)
% t - Time array given the Sampling Frequency


    id_str = string( strcat('./Data/s', int2str(id), '.wav') );
    [s, fs] = audioread(id_str);
    t = (0:length(s)-1) / fs;
    if min(size(s)) > 1
        s = s(:, 1); % If more channel, get only first
    end
end
