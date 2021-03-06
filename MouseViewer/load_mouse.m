function mouse = load_mouse(mouse_index)
%
%
%
%

% Created: SRO - 5/30/12

if nargin < 1 || isempty(mouse_index)
    userInput = 1;
else
    userInput = 0;
end

rdef = RigDefs;

% Get list of mouse structs
mouse_dir = rdef.Dir.Mouse;
list = dir([rdef.Dir.Mouse '*_mouse.mat']);
list = list(end:-1:1);

if userInput
    for i = 1:length(list)
        tmp = findstr('_',list(i).name);
        mouse_list{i,1} = list(i).name(1:tmp(end)-1);
    end
    
     %    mouse_list = mouse_list(end:-1:1);
    
    %AR 10/19/2016 code to open mouse list on the right monitor
    defaultFigPos=get(0, 'defaultfigureposition');
    figpos=[2500 400 defaultFigPos(3:4)];
    set(0,'defaultfigureposition',figpos);
    
    [mouse_index,v] = listdlg('PromptString','Select mouse:','ListSize',[250 250],...
        'ListString',mouse_list,'SelectionMode','single');
    
    set(0,'defaultfigureposition', defaultFigPos);
    a = 1;
end

if ~userInput || v
    file_name = [mouse_dir list(mouse_index).name];
    mouse = loadvar(file_name);
else
    mouse = [];
end








