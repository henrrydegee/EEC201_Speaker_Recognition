function genNoiseFiles()
    tNoise = ["white", "pink", "brown"];

    for i = 1:11
        [s, fs] = getFile(i);
        for j = 1:length(tNoise)
           typeNoise = tNoise(j);
           sn = addNoise(s, typeNoise);
           sn = ampNorm(sn); % Scale down amplitude to max 1
           fileName = string(strcat("./Data/noise/s", num2str(i), typeNoise, ".wav"));
           audiowrite(fileName, sn, fs);
        end
    end
end

function y = ampNorm(s)
    % Normalizes the signal to max amp of 1
    k = 1 / max(abs(s)); % Gain Factor
    y = k * s; % Multiply
end