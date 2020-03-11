function sout = prefilter(sound)
    % Apply low pass filter on sound input
    % Also surpresses dc
    
    f = [0 .01 .02 .5 .51 1]; % passband stopband frequencies
    a = [0 0 1 1 0 0]; % ideal amplitude of the bands
    n = 72;

    pmout = firpm(n, f, a); % get the fir filter
    
    sout = conv(sound, pmout);
end