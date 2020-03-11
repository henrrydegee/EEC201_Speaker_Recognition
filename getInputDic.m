function inputDic = getInputDic(noise, N, p, pTrain, M, K, thres_distortion)
    inputDic = table;
    for i = 1:11
        [s, fs] = getFile(i);
        stri = string(strcat("s", num2str(i)));
        if nargin == 0
            inputDic = train42(s, fs, stri, inputDic, false);
        else
            inputDic = train42(s, fs, stri, inputDic, false, ...
                noise, N, p, pTrain, M, K, thres_distortion);
        end
    end
end