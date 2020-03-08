%% Get Audio from mic demo

Fs = 44100; % sampling frequency
nBits = 16 ; % num bits per sample
nChannels = 1; % only want mono channel for simplicity
ID = -1; % default audio input device 
recObj = audiorecorder(Fs,nBits,nChannels,ID);
record(recObj); % toggle start

% Wait until stop
pause(3); % dummy code for recording

stop(recObj); % toggle stop

s = getaudiodata(recObj);

s = 0.5 * s./ max(abs(s)); % norm amp for reasons

plot((0:length(s)-1)/Fs, s);

sp = audioplayer(s, Fs);

% TODO: implement noise filter