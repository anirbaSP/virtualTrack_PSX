function run = updateRun(run,force_update)
%
%
%
%
%

% Created: SRO - 6/20/12


if nargin < 2 || isempty(force_update)
    force_update = 0;
end

f_save = 1;

run = addAnalysisToRun(run);
flds = fields(run.analysis.update);


for i = 1:length(flds)
    if force_update
        run.analysis.update.(flds{i}) = 0;
    end
    if ~run.analysis.update.(flds{i})
        switch flds{i}
            case 'trial_cleanup'
                run = cleanupRunPositionData(run);
                run.analysis.update.(flds{i}) = 1;
                
            case 'velocity_acceleration'
                run = computeRunVelocityAcceleration(run);
                run.analysis.update.(flds{i}) = 1;
                
            case 'rest_periods'
                run = findRestPeriods(run);
                run.analysis.update.(flds{i}) = 1;
                
            case 'obj_encountered'
                run = objEncountered(run);
                run.analysis.update.(flds{i}) = 1;
                
            case 'obj_trk'
                run = make_obj_trk(run);
                run.analysis.update.(flds{i}) = 1;
                
            case 'hold_time_per_object'
                run = computeHoldTimePerObj(run);
                run = addChoiceData(run);
                run.analysis.update.(flds{i}) = 1;
                
            case 'obj_type'
                % Add obj_type and obj_center to 
                run = addObjInfoToPmat(run);
              
        end
    end
end

if f_save
    saveRun(run);
end