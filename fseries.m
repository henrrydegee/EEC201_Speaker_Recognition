%% Signal Generator
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