function run = computeHoldTimePerObj(run)
%
%
%
%

% Created: SRO - 6/25/12




trials = 1:size(run.position_data,2);

% pmat = removeRestFromPositionData(run.position_data);
pmat = run.position_data;
p = pmat(:,:,2);
t = pmat(:,:,1);

fld = {'trial','reward','time_in_zone','led','encounter_time',...
    'position_data_ind','obj_centers','entry_ind'};
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
    
    % Add encounter time in session (kluge)
    for n = 1:length(obj)
        obj(n).encounter_time = run.trial(i).trk.encounter_time(n);
        obj(n).obj_centers = run.trial(i).trk.obj_centers(n);
        obj(n).position_data_ind = run.trial(i).trk.position_data_ind(n);
        obj(n).entry_ind = run.trial(i).trk.entry_ind(n);
        
    end
    
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
            run.obj_trk.obj(tmp_obj_code).led(end+1,1:size(run.led_state,2)) = obj(n).led_on;
        end
        
        % Find samples between reward zone
        k = p(:,trial_ind) >= obj(n).target_zone(2) & p(:,trial_ind) <= obj(n).target_zone(1);
        k_ind = find(k==1); % Need to include sample prior to entering zone
        if k_ind
            k_ind = min(k_ind)-1;
            k(k_ind) = true;
        end
        tmp = t(k,trial_ind);
        
        % Compute time in reward zone
        tmp = sum(diff(tmp));
        run.obj_trk.obj(tmp_obj_code).time_in_zone(end+1) = tmp;
        
        % Additional fields
        run.obj_trk.obj(tmp_obj_code).encounter_time(end+1) = obj(n).encounter_time;
        run.obj_trk.obj(tmp_obj_code).position_data_ind(end+1) = obj(n).position_data_ind;
        run.obj_trk.obj(tmp_obj_code).obj_centers(end+1) = obj(n).obj_centers;
        run.obj_trk.obj(tmp_obj_code).entry_ind(end+1) = obj(n).entry_ind;
        
        
    end
    
end

disp('***** Computed hold time per object in RUN struct *****')

