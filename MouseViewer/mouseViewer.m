function varargout = mouseViewer(varargin)
%
%
%
%
%

% Created: SRO - 5/30/12

% Last Modified by GUIDE v2.5 19-Feb-2013 13:01:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mouseViewer_OpeningFcn, ...
    'gui_OutputFcn',  @mouseViewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function mouseViewer_OpeningFcn(hObject, eventdata, handles, varargin)

rdef = RigDefs;

% Set position
tmp = get(handles.hfig,'Position');
set(handles.hfig,'Position',[102 20.3 tmp(3) tmp(4)]);

% Load most recent mouse (Make .mat file state information)
mouse = load_mouse(1);
handles.mouse = mouse;

% Update mouseViewer
handles = updateMouseViewer(mouse,handles);

% Update handles structure
guidata(hObject, handles);



function varargout = mouseViewer_OutputFcn(hObject, eventdata, handles)


function pb_save_Callback(hObject, eventdata, handles)

% Get current mouse struct
mouse = handles.mouse;
file_name = mouse.file;

% Get current table
mouse_table = get(handles.table_mouse,'Data');

% Convert to struct
mouse = mouseTable2Struct(mouse_table,mouse);

% Verify file name
if ~strcmp(file_name,mouse.file)
    disp('*** FILENAME CHANGED ***')
end

% Save mouse struct
save(mouse.file,'mouse');

disp(['Saved mouse:' ' ' mouse.file]);

handles = updateMouseViewer(mouse,handles);

handles.mouse = mouse;
guidata(hObject,handles);


function pb_new_Callback(hObject, eventdata, handles)
mouse = makeMouseStruct();
handles = updateMouseViewer(mouse,handles);


function mouse = mouseTable2Struct(mouse_table,mouse)

if isempty(mouse)
    mouse = [];
end

% Remove empty fields
tmp = strcmp(mouse_table(:,1),'');
mouse_table(tmp,:) = [];

% Get fields
flds = mouse_table(:,1);

for i = 1:length(flds)
    mouse.(flds{i}) = mouse_table{i,2};
end

% mouse.file = setMouseFile(mouse);

function pb_load_Callback(hObject, eventdata, handles)
mouse = load_mouse();
if ~isempty(mouse)
    handles = clearRun(handles);
    handles = updateMouseViewer(mouse,handles);
end


function pb_forward_arrow_Callback(hObject, eventdata, handles)

[m_index n_mice] = findCurrentMouseIndex(handles);
mouse = load_mouse(mod(m_index-2,n_mice)+1);
handles = clearRun(handles);
handles = updateMouseViewer(mouse,handles);


function pb_back_arrow_Callback(hObject, eventdata, handles)
[m_index n_mice] = findCurrentMouseIndex(handles);
mouse = load_mouse(mod(m_index,n_mice)+1);
handles = clearRun(handles);
handles = updateMouseViewer(mouse,handles);


function handles = clearRun(handles)
set(handles.tx_active_run_file,'String','')
evalin('base','clear r')
handles.run = [];
guidata(handles.hfig,handles);



function [m_index n_mice] = findCurrentMouseIndex(handles)
rdef = RigDefs;
% Get list of mouse structs
mouse_dir = rdef.Dir.Mouse;
list = dir([rdef.Dir.Mouse '*_mouse.mat']);
list = list(end:-1:1);
list = {list.name}';
n_mice = length(list);

% Set current mouse
[junk current_mouse] = fileparts(handles.mouse.file);

% Find current mouse in list
m_index = find(strncmp(current_mouse,list,length(current_mouse)));


function pb_virus_Callback(hObject, eventdata, handles)

function pb_set_info_Callback(hObject, eventdata, handles)

function pb_delete_Callback(hObject, eventdata, handles)
[junk mouse_file_name] = fileparts(handles.mouse.file);

% Construct a questdlg with three options
choice = questdlg(['Delete: ' mouse_file_name ' ?'], ...
    'Delete Mouse', ...
    'Yes','No','No');
% Handle response
switch choice
    case 'Yes'
        delete([handles.mouse.file '.mat']);
        handles = updateMouseViewer([],handles);
    case 'No'
end

function chk_active_only_Callback(hObject, eventdata, handles)

function pb_delete_session_Callback(hObject, eventdata, handles)

mouse = handles.mouse;
[mouse ok] = deleteSessions(mouse);

if ok
    handles.mouse = mouse;
    pb_update_session_table_Callback(handles.pb_update_session_table, [], handles)
    handles = guidata(hObject);
    
    pb_save_Callback(hObject, eventdata, handles);
    handles = guidata(hObject);
    
    mouse = handles.mouse;
    handles = updateMouseViewer(mouse,handles);
    
    guidata(hObject,handles);
end





function pb_load_run_Callback(hObject, eventdata, handles)

mouse = handles.mouse;
run = setRun(handles,mouse,[]);


function run = setRun(handles,mouse,session_ind,table_ind)

if nargin < 3 || isempty(session_ind);
    [session_ind table_ind] = runListDialog(mouse,'single');
end

if nargin < 4 || isempty(table_ind);
    if isempty(table_ind)
        table_ind = '';
    end
end


if isfield(mouse,'vtrack')
    if ischar(session_ind) && strcmp(session_ind,'Most recent')
        session_ind = length(mouse.vtrack.session);
        table_ind = 1;
    end
    
    if session_ind
        try
            r = loadvar(mouse.vtrack.session(session_ind).run_file);
            [junk fname] = fileparts(mouse.vtrack.session(session_ind).run_file);
        catch
            fname = mouse.vtrack.session(session_ind).run_file;
            tmp = strfind(fname,'\');
            fname = fname(tmp(end)+1:end);
            rdef = RigDefs;
            r = loadvar([rdef.Dir.Run fname '.mat']);
        end
        putvar(r);
        set(handles.tx_active_run_file,'String',[num2str(table_ind) ':   ' fname(5:end)])
        run = r;
        handles.run = run;
    else
        set(handles.tx_active_run_file,'String','')
        run = [];
        handles.run = run;
    end
else
    run = [];
    handles.run = run;
    set(handles.tx_active_run_file,'String','')
end

handles = updateMouseViewer(mouse,handles);
guidata(handles.hfig,handles);

function pb_forward_run_Callback(hObject, eventdata, handles)

% If no run struct loaded yet, open most recent
if ~isfield(handles,'run') || isempty(handles.run)
    run = setRun(handles,handles.mouse,'Most recent',[]);
else
    [r_index n_run] = findCurrentRunIndex(handles);
    new_session_ind = mod(r_index,n_run)+1;
    table_ind = n_run - new_session_ind + 1;
    run = setRun(handles, handles.mouse, new_session_ind,table_ind);
    pause(0.2);
end

function pb_back_run_Callback(hObject, eventdata, handles)
% If no run struct loaded yet, open most recent
if ~isfield(handles,'run') || isempty(handles.run)
    run = setRun(handles,handles.mouse,'Most recent',[]);
else
    [r_index n_run] = findCurrentRunIndex(handles);
    new_session_ind = mod(r_index-2,n_run)+1;
    table_ind = n_run - new_session_ind + 1;
    run = setRun(handles, handles.mouse, new_session_ind,table_ind);
    pause(0.2);
end

function [r_index n_run] = findCurrentRunIndex(handles)
rdef = RigDefs;
mouse = handles.mouse;
% Get list of run structs
list = {mouse.vtrack.session(:).run_file}';
n_run = length(list);

% Get current run file name
if isfield(handles.run,'file')
    current_run = handles.run.file;
else
    current_run = [rdef.Dir.vTrackData handles.run.name];
end

% Find current run in list
r_index = find(strncmp(current_run,list,length(current_run)));



function pb_update_run_Callback(hObject, eventdata, handles)

mouse = handles.mouse;
session_ind = runListDialog(mouse,'multiple'); pause(0.1);
force_update = get(handles.chk_force_update,'Value');

for i = 1:length(session_ind)
    run = loadvar(mouse.vtrack.session(session_ind(i)).run_file);
    run = updateRun(run,force_update);
end


function [session_ind table_ind] = runListDialog(mouse,n_selection)

str = getSessionList(mouse);
[s,ok] = listdlg('PromptString','Choose session:',...
    'ListSize',[300 500],...
    'ListString',str,...
    'SelectionMode',n_selection);
table_ind = s;
session_ind = length(mouse.vtrack.session) - s + 1;


function pb_weight_Callback(hObject, eventdata, handles)

function ed_n_run_sessions_displayed_Callback(hObject, eventdata, handles)

function ed_n_run_sessions_displayed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_force_update.
function chk_force_update_Callback(hObject, eventdata, handles)
% hObject    handle to chk_force_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_force_update


% --- Executes on button press in pb_save_run_struct.
function pb_save_run_struct_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save_run_struct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function pb_trial_viewer_Callback(hObject, eventdata, handles)

plotRunTrial(handles.run,1,0)


function pb_performance_Callback(hObject, eventdata, handles)

mouse = handles.mouse;

% Index of run structs to analyze together
[session_ind table_ind] = runListDialog(mouse,'multiple');

% Load run structs

for i = 1:length(session_ind)
    tmp = loadvar(mouse.vtrack.session(session_ind(i)).run_file);
    if i == 1;
        if ~isfield(tmp,'session_end_time')
            tmp.session_end_time = 0;
        end
        r(i) = tmp;
    else
        flds_r = fieldnames(r);
        flds_tmp = fieldnames(tmp);
        if ~isfield(tmp,'session_end_time')
            tmp.session_end_time = 0;
        end
        tmp = orderfields(tmp);
        r = orderfields(r);
        r(i) = tmp;
    end
    
end

plotHoldTimePerObj(r);
a = 1;


function pb_session_summary_Callback(hObject, eventdata, handles)

mouse = handles.mouse;
% Index of run structs to analyze together
[session_ind table_ind] = runListDialog(mouse,'multiple');

f_save = get(handles.chk_save,'Value');

for i = 1:length(session_ind)
    
    try
        r = loadvar(mouse.vtrack.session(session_ind(i)).run_file);
        session_summary(r,f_save);
    catch
        disp(['Couldnt save RUN:' r.name]);
    end
    
end





function pb_update_session_table_Callback(hObject, eventdata, handles)

mouse = handles.mouse;
[mouse s_table] = makeSessionTable(mouse);
handles.mouse = mouse;
guidata(hObject,handles);
handles = updateMouseViewer(mouse,handles);
putvar(mouse)


function pb_add_session_Callback(hObject, eventdata, handles)
mouse = handles.mouse;
mouse = addSession(mouse);
handles.mouse = mouse;
saveMouse(mouse);
guidata(handles.hfig,handles);
handles = updateMouseViewer(mouse,handles);


function pb_across_session_Callback(hObject, eventdata, handles)


mouse = handles.mouse;
% Index of run structs to analyze together
[session_ind table_ind] = runListDialog(mouse,'multiple');


plotDprimeOverTraining(mouse,session_ind)
%


% --- Executes on button press in chk_save.
function chk_save_Callback(hObject, eventdata, handles)
% hObject    handle to chk_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_save
