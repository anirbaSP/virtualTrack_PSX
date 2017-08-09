function run = objEncountered(run)
%
%
%
%

% Created: SRO - 6/17/12




for i = 1:run.trial_number
    % Get position vector for this run trial
    p = run.position_data(:,i,2);
    t = run.position_data(:,i,1);
    
    % Get trk struct for this trial
    trk = run.trial(i).trk;
    
    % Set object codes (** TO DO: set obj codes in makeTrkStruct)
    if ~isfield(trk,'code')
        trk = makeObjCodeMat(trk);
    end
    if ~isfield(trk,'obj_list')
        trk = setObjCodes(trk);
    end
    
    %     % Compute run distance (** TO DO: deal with repeated laps of track)
    %     distance = computeRunDistance(p,trk);
    %     p_end = trk.length - distance;
    %     z = trk.obj_centers + trk.target_zone_width(1) >= p_end;
    % %         z = trk.obj_centers  >= p_end;
    %     trk.obj_encountered = z;
    
    % -- Determine obj encountered differently
    for n = 1:length(trk.obj)
        target_zone = trk.obj(n).target_zone;
        tmp = ((p < target_zone(1)) & (p > target_zone(2)));
        trk.obj_encountered(n) = any(tmp);
        if trk.obj_encountered(n)
            trk.encounter_time(n) = run.trial(i).start_time ...
                + t(find(tmp,1));
            trk.position_data_ind(n) = find(tmp,1);
            
            % Add entry point
            tmp = p < (run.trial(i).trk.obj(n).center + run.trial(i).trk.obj(n).size ...
                + run.trial(i).trk.screen_width_pix/2);
            trk.entry_ind(n) = find(tmp,1);
            
        else
            trk.encounter_time(n) = NaN;
            trk.position_data_ind(n) = NaN;
            trk.entry_ind(n) = NaN;
        end
    end
    
    run.trial(i).trk = trk;
    
end

disp('***** Object encounters added to RUN struct *****')


function distance = computeRunDistance(p,trk)

lap_thresh = 0.5*trk.length;

tmp = diff([trk.length; p]);

tmp(tmp > lap_thresh) = 0;

distance = -nansum(tmp);


% function c = addObjEncountered(run,trk)
% % Get count of encounter for each object on each trial
%
% for i = run.obj_list
%     tmp = trk.obj_list(trk.obj_encountered);
%     c(i) = sum(tmp == i);
% end
%
