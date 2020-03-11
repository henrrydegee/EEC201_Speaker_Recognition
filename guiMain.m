%% GUI Main
% Run this to run the GUI
% Author: Team 42 - Henrry Gunawan, Wai Cheong Tsoi
clear; close all; clc;

%% Global Variables
global recObj isTrain spkName board Fs path inputDic
[recObj, Fs] = getaudrec();
isTrain = 1;
spkName = "Name";
path = './Data/';
inputDic = getInputDic();

%% Initialize
board = guiInit();

% Set Function Associations
set(board.recButt, 'callback', @recAud);
set(board.stoButt, 'callback', @stoAud, 'Enable', 'off');
set(board.bg, 'SelectionChangedFcn',@bsel);
set(board.namFiel, 'callback', @namFie);
set(board.patFiel, 'callback', @patFie);
set(board.loaButt, 'callback', @loaAud);

%% Train/Verify Function
function processSound(s, fs)
    global isTrain spkName inputDic
    
    if isTrain
        % Send to train
        setOutText(string(strcat("Training for: ", spkName)));
        inputDic = train42(s, fs, spkName, inputDic, false);
        setOutText(string(strcat("Trained: ", spkName)));
    else
        % Send to find speaker
        outSpkr = test42(s, fs, inputDic);
        isValid = 1; % TODO: get validity of speaker
        if isValid
            otxt = string(strcat("Speaker is: ", outSpkr));
            setOutText(otxt);
        else
            setOutText(["Match not found."]);
        end
    end
end

%% Callback Functions
function loaAud(~, ~)
    global path
    [s, Fs] = getSoundFromPath(path);
    setOutText(['Loading sound from path: ', path]);
    processSound(s, Fs);
    pause(1);
end

function recAud(~, ~)
    global recObj board
    record(recObj); % toggle start
    set(board.stoButt, 'Enable', 'on');
    set(board.recButt, 'Enable', 'off');
    setOutText("Recording");
end

function stoAud(~, ~)
    global recObj board Fs
    stop(recObj); % toggle stop
    set(board.stoButt, 'Enable', 'off');
    set(board.recButt, 'Enable', 'on');
    setOutText("Stopped");
    
    % Get sound data from recorder and forward it
    s = getaudiodata(recObj);
    processSound(s, Fs);
end

function namFie(hObj, ~, ~)
    global spkName
    spkName = get(hObj, 'String');
    setOutText(['Set name to: ' spkName]);
    spkName = string(spkName);
end

function patFie(hObj, ~, ~)
    global path
    path = get(hObj, 'String');
    setOutText(['Set path to:' path]);
end

function bsel(~ ,event)
    global isTrain
    str = event.NewValue.String;
    isTrain = (str == "Train");
    setOutText(['Mode: ' str]);
end

function setOutText(str)
    global board
    set(board.outText, 'string', str);
end

%% Helper Function
function [obj, Fs] = getaudrec()
% Returns an audio recorder object obj and sampling frequency Fs
Fs = 44100; % sampling frequency
nBits = 16 ; % num bits per sample
nChannels = 1; % only want mono channel for simplicity
ID = -1; % default audio input device

obj = audiorecorder(Fs,nBits,nChannels,ID);
end