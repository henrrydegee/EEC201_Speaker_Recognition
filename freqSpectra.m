function freqSpectra(xn, Fs, N)
    %tIn = 0:length(xn)-1 ;
    %tIn = tIn / Fs;
    
    f = Fs*(0:(N/2))/N;
    Xk = fft(xn, N);
    Pk = abs( Xk(1:(floor(N/2)+1) ) );
    figure; plot(f, Pk); hold on;
    xlabel('Frequency (Hz)')
    ylabel('Amplitude')
    title('Frequency Spectra')
end