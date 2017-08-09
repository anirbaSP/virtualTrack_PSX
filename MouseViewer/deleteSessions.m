function [mouse ok] = deleteSessions(mouse)
%
%
%
%
%

% Created: SRO - 6/11/12




str = getSessionList(mouse);

[s,ok] = listdlg('PromptString','Delete sessions:',...
    'ListSize',[300 500],...
    'ListString',str);

s_ind = -s + length(mouse.vtrack.session) + 1;

if ok
    for i = 1:length(s_ind)
        disp(['Deleting ... ' mouse.vtrack.session(s_ind(i)).run_file]);
    end
    mouse.vtrack.session(s_ind) = [];
    mouse.vtrack.session_ind = length(mouse.vtrack.session);
end

