function run = make_obj_trk(run)
%
%
%
%
%

% Created: SRO - 6/22/12



if isfield(run,'track_table')
    trk_table = run.track_table;
else  % For older run files need to look up table in mouse struct
    
    % Find mouse file
    rdef = RigDefs;
    fname = dir([rdef.Dir.Mouse run.mouse_code '*']);
    mouse = loadvar([rdef.Dir.Mouse fname.name]);
    sessionInd = findRunSession(run,mouse);
    trk_table = mouse.vtrack.session(sessionInd).track_table;
    run.track_table = trk_table;
end

obj_trk = makeTrkStruct(trk_table,1);
run.obj_trk = obj_trk;

disp('***** obj_trk added to RUN struct *****')


