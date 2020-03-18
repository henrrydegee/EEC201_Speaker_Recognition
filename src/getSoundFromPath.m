function [s, fs] = getSoundFromPath(path)
    % Gets sound file specified from path
    % Returns the sound data s and sampling frequency fs
    
    [s, fs] = audioread(path);
    if min(size(s)) > 1
        s = s(:, 1); % If more channel, get only first
    end
end