%% Twinkle Twinkle Little Star
function [s, tTotal] = twinkle
    fs = 48000;
    t = 0:0.5*fs;
    do = fseries(261, 261, t, fs, 1);
    sol = fseries(391, 391, t, fs, 1);
    la = fseries(440, 440, t, fs, 1);
    fa = fseries(349, 349, t, fs, 1);
    mi = fseries(329, 329, t, fs, 1);
    re = fseries(294, 294, t, fs, 1);
    s = [do, (1/3).*(do+mi+sol), sol, sol, la, (1/3).*(do+fa+la), sol, ...
        fa, fa, mi, mi, re, re, (1/3).*(do+mi+sol)];
    tTotal = [t, t+t, 2.*t+t, 3.*t+t, 4.*t+t, 5.*t+t, 6.*t+t, ...
        7.*t+t, 8.*t+t, 9.*t+t, 10.*t+t, 11.*t+t, 12.*t+t, 13.*t+t];
    plot(tTotal./fs, s)
    title('Twinkle Twinkle Little Star')
    xlabel('Time (s)')
    ylabel('Amplitude')
end

function xn = fseries(f1, f2, n, fs, step)
% Generates Fourier Series with given frequencies
% Input:
% f1 = Starting Frequency
% f2 = Ending Frequency
% n = Time Domain / Domain of Signal
% fs = Sampling Frequency
% step = Steps between the consecutive frequencies
% Output:
% xn = x[n] Fourier Series

    xn = 0;     % Initialization of x[n]
    for f = f1:step:f2    % Fourier Series frequency
        xn = xn + sin( 2.*pi.*f.* (n ./fs) ) ;%...
            %+ cos( 2.*pi.*f.* (n ./fs) );
        if ( f > 1)
            xn = xn * 100 ./ (f);
        end
    end
end