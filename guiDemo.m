%% GUI Demo

%% Local Parameters
Fs = 44100; % sampling frequency
nBits = 16 ; % num bits per sample
nChannels = 1; % only want mono channel for simplicity
ID = -1; % default audio input device 

%% Global Variables
global recObj isTrain spkName board
recObj = audiorecorder(Fs,nBits,nChannels,ID);
isTrain = 1; % Default is train
spkName = "Name";

%% UI Setup
% Set UI Window Size
screen = get(0, 'ScreenSize');
x0 = screen(3)/2-400; y0 = screen(4)/2-200;
board.fig = figure('Name', 'GUIDemo', 'NumberTitle', 'off', 'position', [x0, y0, 700, 200]);
set(board.fig, 'Color', [1,1,1]);

% Set Record button
board.recButton = uicontrol('style', 'pushbutton', 'position', ...
    [100, 125, 100, 35], 'string', 'Record');
set(board.recButton, 'callback', @recAud);

% Set Stop button
board.stoButton = uicontrol('style', 'pushbutton', 'position', ...
    [100, 75, 100, 35], 'string', 'Stop');
set(board.stoButton, 'callback', @stoAud);

% Set Train/Test Radio Button
board.bg = uibuttongroup('Position',[.5, .6, .3, .2], ...
    'SelectionChangedFcn',@bsel);
r1 = uicontrol(board.bg,'Style', 'radiobutton', 'String','Train',...
	'Position',[40 5 50 30]);
r2 = uicontrol(board.bg,'Style','radiobutton', 'String','Test',...
	'Position',[140 5 50 30]);

% Set Name Field
board.nameField = uicontrol('style', 'edit', 'position', [440 75 160 35], ...
    'string', 'Name', 'FontSize', 12);
set(board.nameField, 'callback', @namFie);
board.nameText = uicontrol('style', 'text', 'FontSize', 12, ...
    'FontAngle', 'italic', 'position', [300 70 120 35], ...
    'BackgroundColor', [1 1 1], 'string', 'Speaker Name: ');

% Set Output Text Field
board.outText = uicontrol('style', 'text', 'FontSize', 14, ...
    'position', [0 25 700 35], ...
    'BackgroundColor', [1 1 1], 'string', 'Team 42');

%% Callback Functions
function recAud(~, ~)
    global recObj
    record(recObj); % toggle start
    setOutText("Recording");
end

function stoAud(~, ~)
    global recObj
    stop(recObj); % toggle stop
    setOutText("Stopped");
end

function namFie(hObj, ~, ~)
    global spkName
    spkName = get(hObj, 'String');
    setOutText(['Set name to: ' spkName]);
end

function bsel(~ ,event)
    global isTrain
    str = event.NewValue.String;
    if (str == "Test")
        isTrain = 0;
    elseif str == "Train"
        isTrain = 1;
    else
        disp(['Error! ' str]);
    end
    setOutText(['Mode: ' str]);
end

function setOutText(str)
    global board
    set(board.outText, 'string', str);
end