function [s, fs] = getSoundFromPath(path)
    [s, fs] = audioread(path);
    if min(size(s)) > 1
        s = s(:, 1); % If more channel, get only first
    end
end