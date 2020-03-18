function inputDic = getInputDic(noise, N, p, pTrain, M, K, thres_distortion)
    % Creates the codebook by training with all 11 training data
    % Returns the codebook inputDic

    inputDic = table; % Initialize a table
    for i = 1:11 % for each speaker, train
        [s, fs] = getFile(i, "train");
        stri = string(strcat("s", num2str(i)));
        if nargin == 0
            inputDic = train42(s, fs, stri, inputDic, false);
        else
            inputDic = train42(s, fs, stri, inputDic, false, ...
                noise, N, p, pTrain, M, K, thres_distortion);
        end
    end
end