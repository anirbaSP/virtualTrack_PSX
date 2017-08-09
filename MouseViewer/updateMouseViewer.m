function handles = updateMouseViewer(mouse,handles)

if isempty(mouse)
    mouse = load_mouse();
end

% Make sure run file names point at correct directory
mouse = confirmRunFiles(mouse);

setMouseTable(mouse,handles);
[mouse s_table] = setSessionTable(mouse,handles);
set(handles.txt_mouse_code,'String',mouse.mouse_code);
handles.mouse = mouse;
putvar(mouse);
put_mv_handles(handles);
guidata(handles.hfig,handles);