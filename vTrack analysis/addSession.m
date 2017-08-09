function mouse = addSession(mouse)
%
%
%
%
%

% Created: SRO - 2/6/13


% Choose which 'run' file to add


rdef = RigDefs;

fname = uigetfile([ [rdef.Dir.Run '*_' mouse.mouse_code '_*'] '*.mat'],'MultiSelect','on');


for i = 1:size(fname,1)
    if iscell(fname)
        tmp = fname{i};
    else
        tmp = fname;
    end
    r = loadvar([rdef.Dir.Run tmp]);

    a = 1;
    session.date = r.session_end_time;
    session.track_table = r.track_table;
    session.run_file = r.file;
   
    mouse.vtrack.session(end+1) = session;
end




