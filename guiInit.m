function board = guiInit()
% Sets up a figure GUI for interaction
% Returns the board object for control

% Set UI Window Size
screen = get(0, 'ScreenSize');
x0 = screen(3)/2-400; y0 = screen(4)/2-200;
board.fig = figure('Name', "Team 42: Speaker Recognition GUI - Speak Louder Please", ...
    'NumberTitle', 'off', 'position', [x0, y0, 700, 250]);
set(board.fig, 'Color', [1,1,1]);

% Set Record button
board.recButt = uicontrol('style', 'pushbutton', 'position', ...
    [100, 125, 100, 35], 'string', 'Record');

% Set Stop button
board.stoButt = uicontrol('style', 'pushbutton', 'position', ...
    [100, 75, 100, 35], 'string', 'Stop');

% Set load button
board.loaButt = uicontrol('style', 'pushbutton', 'position', ...
    [100, 175, 100, 35], 'string', 'Load');

% Set Train/Test Radio Button
board.bg = uibuttongroup('Position',[.5, .3 .3, .15]);
uicontrol(board.bg,'Style', 'radiobutton', 'String','Train',...
	'Position',[40 5 50 30]);
uicontrol(board.bg,'Style','radiobutton', 'String','Find',...
	'Position',[140 5 50 30]);

% Set Name Field
board.namFiel = uicontrol('style', 'edit', 'position', [400 125 200 35], ...
    'string', 'Name', 'FontSize', 12);
board.namText = uicontrol('style', 'text', 'FontSize', 12, ...
    'FontAngle', 'italic', 'position', [275 120 120 35], ...
    'BackgroundColor', [1 1 1], 'string', 'Speaker Name: ');

% Set Path Field
board.patFiel =  uicontrol('style', 'edit', 'position', [400 175 200 35], ...
    'string', './Data/', 'FontSize', 12);
board.patText = uicontrol('style', 'text', 'FontSize', 12, ...
    'FontAngle', 'italic', 'position', [275 170 120 35], ...
    'BackgroundColor', [1 1 1], 'string', 'Path: ');

% Set Output Text Field
board.outText = uicontrol('style', 'text', 'FontSize', 14, ...
    'position', [0 20 700 40], ...
    'BackgroundColor', [1 1 1], 'string', 'Team 42');
end