function [time_unrolled, banks_unrolled, amp_unrolled] ...
    = preProcess(time, banks, ampMap)

    thres = 0.05; % Threshold Eliminate Background
    preAmp = ampMap;
    pretime = repmat(time', 20, 1);
    preBank = repmat((banks)', 1, size(ampMap, 2) );
    
    % Remove Unnecessary Change in Amplitude
    deltaThres = 0.05; % To try: db2mag(-40);
    for row = 1:size(ampMap, 1)
        initialAmp = preAmp(row,1); % Amplitude @ t=0
        
        for col = 2:size(ampMap, 2)
            if (abs(initialAmp - ampMap(row,col) ) < deltaThres)
                preAmp(row, col) = 0;
                pretime(row, col) = -1;
                preBank(row, col) = -1;
            end
        end
    end
    
    % Remove Background Noise Redundancy
    for row = 1:size(ampMap, 1)
        for col = 1:size(ampMap, 2)
            if (abs(ampMap(row,col) ) < thres)
                preAmp(row, col) = 0;
                pretime(row, col) = -1;
                preBank(row, col) = -1;
            end
        end
    end

    
    [time_unrolled, banks_unrolled, amp_unrolled] ...
        = surfToXYZ(pretime, preBank, preAmp);

    % Process stuff (Remove Redundancy)
    curr_idx = 1;
    for data_pt = 1:length(amp_unrolled)
        if (time_unrolled(curr_idx,1)==-1 & ...
                banks_unrolled(curr_idx,1)==-1 & ...
                amp_unrolled(curr_idx,1)==0)
            
            time_unrolled(curr_idx,:) = [];
            banks_unrolled(curr_idx,:) = [];
            amp_unrolled(curr_idx,:) = [];
            curr_idx = curr_idx-1;
        end
        if (time_unrolled(curr_idx,1)==0 & ...
                banks_unrolled(curr_idx,1)==0 & ...
                amp_unrolled(curr_idx,1)==0)
            
            time_unrolled(curr_idx,:) = [];
            banks_unrolled(curr_idx,:) = [];
            amp_unrolled(curr_idx,:) = [];
            curr_idx = curr_idx-1;
        end
        curr_idx = curr_idx+1;
    end
end