function saveRunFromErrorSession(mouse,run)
%
%
%
%

% Created: SRO - 2/6/13



rdef = RigDefs;

% Save run file on analysis PC
fname = run.name;
fname = [rdef.Dir.vTrackData fname];
fname = checkIfFileExists(fname);
run.file = fname;
saveRun(run);

% Load most recent mouse file
mouse = loadvar(mouse.file);

sessionInd = length(mouse.vtrack.session)+1;
flds = {'date','track_table','run_file'};
for i = 1:length(flds)
    switch flds{i}
        case 'date'
            mouse.vtrack.session(sessionInd).(flds{i}) = run.session_start_time;
            
        case 'track_table'
            mouse.vtrack.session(sessionInd).(flds{i}) = run.track_table;
            
        case 'run_file'
            mouse.vtrack.session(sessionInd).(flds{i}) = run.file;
    end
end


saveMouse(mouse);

