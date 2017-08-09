function obj = findTimeObjPosition(run)
%
%
%
%

% Created: SRO - 10/11/12


trials = 1:size(run.position_data,2);

% pmat = removeRestFromPositionData(run.position_data);
pmat = run.position_data;
p = pmat(:,:,2);
t = pmat(:,:,1);

fld = {'trial','reward','encounter_time','led'};
for i = 1:length(fld)
    if isfield(run.obj_trk.obj,fld{i})
        run.obj_trk.obj = rmfield(run.obj_trk.obj,fld{i});
    end
    run.obj_trk.obj(1).(fld{i}) = [];
end

% Loop through trials
for i = 1:length(trials)
    
    trial_ind = trials(i);
    
    % Get track for current trial
    trk = run.trial(trial_ind).trk;
    obj = trk.obj;
    
    % Filter on objects encountered
    obj = obj(trk.obj_encountered);
    
    % Loop through objects encountered
    for n = 1:length(obj)
        
        % Get code for this object
        tmp_obj_code = obj(n).code;
        
        % Set trial and reward information
        run.obj_trk.obj(tmp_obj_code).trial(end+1) = i;
        run.obj_trk.obj(tmp_obj_code).reward(end+1) = NaN; % placeholder for now
        
        % Determine whether LED trial
        if isfield(run,'use_led') && run.use_led
            run.obj_trk.obj(tmp_obj_code).led(end+1) = obj(n).led_on;
        end
        
        % Find samples flanking reference point
        ref_point = obj(n).center + run.screen_rect(3)*0.25;
        k = find(diff(p(:,trial_ind) > ref_point));
        
        % ***** tmp kluge (deal with nans in p)
        k = k(end);
        
        tmp_time = mean([t(k,trial_ind) t(k+1,trial_ind)]);
        run.obj_trk.obj(tmp_obj_code).encounter_time(end+1) = tmp_time;
%         
%         % Compute time in reward zone
%         tmp = sum(diff(tmp));
%         run.obj_trk.obj(tmp_obj_code).time_in_zone(end+1) = tmp;
    end

end

obj = run.obj_trk.obj;
