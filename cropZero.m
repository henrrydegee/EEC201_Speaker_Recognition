function y = cropZero(s)
    % Deletes the leading and ending zeros
    % Note: Also get rids of -30dB of Amplitude
    
    s2 = round(s, 3); % sensitivity 
    cri = abs(s2) > db2mag(-30);
    y = s(find(cri, 1, 'first'):find(cri, 1, 'last')); % crop
end