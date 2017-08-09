function [mouse s_table] = getSessionTable(mouse)
%
%
%
%
%

% Created: SRO - 2/5/13




if ~isfield(mouse.vtrack,'session_table')
    mouse = makeSessionTable(mouse);
end

s_table = mouse.vtrack.session_table;
