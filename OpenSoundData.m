%% Reading data

% Initialization
id_str = strings(1,10)
% Opening Files
for id = 1:10
    id_str(1, id) = string( strcat('./Data/s', int2str(id), '.wav') );
end

% To test out context:
%id_str(1, 1)

[s1, s1Fs] = audioread(id_str(1, 10) );
sound(s1, s1Fs)