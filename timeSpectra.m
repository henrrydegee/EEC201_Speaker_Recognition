function timeSpectra(inSignal, Fs)
    tIn = 0:length(inSignal)-1 ;
    tIn = tIn / Fs;
    figure
    plot(tIn, inSignal)
    hold on
    xlabel('Time (s)')
    ylabel('Amplitude')
    title('Time Spectra')
end