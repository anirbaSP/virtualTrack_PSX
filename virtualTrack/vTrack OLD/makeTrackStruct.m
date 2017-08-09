function [trk run] = makeTrackStruct(table_track,mouse)
%
%
%
%
%

% Created: SRO 5/24/12


% Screen defaults
sdef = screenDefs;
screenRect = [0 0 sdef.width sdef.height];

% Session paramters
trk.sdef = sdef;
trk.rig = getFromTable(table_track,'Rig');
trk.number_of_trials = str2num(getFromTable(table_track,'Number of trials'));
trk.parallel_port_trigger = str2num(getFromTable(table_track,'Parallel port trigger'));
trk.wait_time_after_trigger = str2num(getFromTable(table_track,'Wait time after trigger'));
trk.threshold_initiation_speed = str2num(getFromTable(table_track,'Threshold initiation speed'));
trk.reward_limit = str2num(getFromTable(table_track,'Reward limit'));
trk.track_update_frequency = str2num(getFromTable(table_track,'Track update frequency'));
trk.track_update_interval = 1/trk.track_update_frequency;
trk.pixels_per_cm = sdef.width/sdef.width_inches/2.54;  % Convert inches to cm
trk.cm_per_volt = pi*6*2.54/1;   % disk circumference*conversion/encoder voltage range
trk.display_offset = round(sdef.width/2-100);

% --- Define run struct
run.n_rewards = 0;
run.time_in_reward_zone = 0;
run.p = 1;
run.distance = 0;
run.trial_number = 1;
run.mouse_code = mouse.mouse_code;
run.reward_limit = trk.reward_limit;
run.number_of_trials = trk.number_of_trials;
run.rig = trk.rig;
run.distance_last_reward = 0;

% Tmp parameters
reward_objects = str2num(getFromTable(table_track,'Target objects'));

for i = 1:run.number_of_trials
    
    % Load previously designed track
    run.trial(i).track_file = getFromTable(table_track,'Track file');
    
    % Gain between movement of disk and object movement on screen
    run.trial(i).track_gain = str2num(getFromTable(table_track,'Track gain'));
    
    % Trial timing parameters
    run.trial(i).trial_duration = str2num(getFromTable(table_track,'Trial duration'));
    run.trial(i).iti = str2num(getFromTable(table_track,'Inter-trial interval'));
    
    % Reward parameters
    run.trial(i).reward_volume = str2num(getFromTable(table_track,'Reward volume'));
    run.trial(i).time_hold_for_reward = str2num(getFromTable(table_track,'Hold for reward'));
    
    % LED paramters
    run.trial(i).led = getFromTable(table_track,'LED');
    
    % Backgorund parameters
    run.trial(i).background_luminance = str2num(getFromTable(table_track,'Background luminance'));
    run.trial(i).background_pix_val = 100;
    
    % Object parameters
    number_of_objects = str2num(getFromTable(table_track,'Number of objects'));
    
    if isempty(number_of_objects)
        number_of_objects = length(str2num(getFromTable(table_track,'Objects')));
    end
    
    object_type = str2num(getFromTable(table_track,'Objects'));
    object_contrast = str2num(getFromTable(table_track,'Object contrast'));
    
    leftIndex = 1;
    for n = 1:number_of_objects
        obj(n).type = object_type(n);
        obj(n).contrast = object_contrast(n);
        obj(n).size = str2num(getFromTable(table_track,'Object size'));
        obj(n).spacing = str2num(getFromTable(table_track,'Object spacing'));
        obj(n).target = reward_objects(n);
        obj(n).target_zone_width = str2num(getFromTable(table_track,'Target zone width'));
        obj(n).reward_available = 1;
        obj(n).reward_volume = run.trial(i).reward_volume;
        
        obj(n).pix_val = obj(n).contrast;    % Change this
        obj(n).background_pix_val = run.trial(i).background_pix_val;
        tmp_rect = CenterRect([0 0 obj(n).size obj(n).size],screenRect);
        obj(n).top = tmp_rect(2);
        obj(n).bottom = tmp_rect(4);
        target_zone_width = str2num(getFromTable(table_track,'Target zone width'));
        obj(n).buffer_left = obj(n).spacing;
        obj(n).buffer_right = obj(n).spacing;
        
        obj(n).panel_left = leftIndex;
        obj(n).panel_right = leftIndex + obj(n).buffer_left + obj(n).size + obj(n).buffer_right;
        objLeft = leftIndex+obj(n).buffer_left;
        objMat = [objLeft obj(n).top objLeft+obj(n).size obj(n).bottom];
        obj(n).rect = objMat;
        leftIndex = objMat(3)+obj(n).buffer_right;
        obj(n).screen_width = sdef.width;
        obj(n).center = (obj(n).rect(3)-obj(n).rect(1))/2+obj(n).rect(1);
        obj(n).target_zone = [obj(n).center+obj(n).target_zone_width(1) obj(n).center-obj(n).target_zone_width(2)];
    end
    
    run.trial(i).obj = obj;
    
    % Cue parameters
    run.trial(i).cue_location = str2num(getFromTable(table_track,'Cue location'));
    run.trial(i).cue_type = '';
    
end



function value = getFromTable(table_track,field)

iRow = strcmp(table_track(:,1),field);

if any(iRow)
    value = table_track(iRow,2);
    if iscell(value)
        value = value{1};
    end
else
%     disp(['The field,' ' ' field ', was not found in track table'])
    value = '';
end




