function [mouse s_table] = setSessionTable(mouse,handles)


if isfield(mouse,'vtrack')
    [mouse s_table] = getSessionTable(mouse);
else
    s_table = '';
end
set(handles.table_session,'Data',s_table);