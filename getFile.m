function [s, fs, t] = getFile(id, type)
    % Reads from ./Data to fetch the file
    % Input:
    % id = {0,1,2,..,10,11}
    % type = (string) {"train", "test"}
    %   |- Note: Default will open train file
    %
    % Outputs:
    % s - Sound array containing amplitudes
    % fs - Sampling Frequency (in Hz)
    % t - Time array given the Sampling Frequency
    

    if nargin == 1
        type = "train";
    end
    
    if type == "train" || type == "test"
        id_str = string( strcat('./Data/', type, '/s', int2str(id), '.wav') );
    else
        error('Unrecognized type: Must be "train" or "test"');
    end

    [s, fs] = audioread(id_str);
    t = (0:length(s)-1) / fs;
    if min(size(s)) > 1
        s = s(:, 1); % If more channel, get only first
    end
end
