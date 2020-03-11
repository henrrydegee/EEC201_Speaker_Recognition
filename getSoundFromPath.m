function [s, fs, t] = getSoundFromPath(path)
    [s, fs] = audioread(path);
    t = (0:length(s)-1) / fs;
    if min(size(s)) > 1
        s = s(:, 1); % If more channel, get only first
    end
end