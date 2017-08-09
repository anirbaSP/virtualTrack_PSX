function run = computeTimeAtObject(run)
%
%
%
%

% Created: SRO - 6/17/12



% Set position data
p = run.position_data;

% Make object track if not make
% obj_trk = makeObjTrk(run);

% Determine whether object encountered for each obj
run = objEncountered(run);

% Loop through trials
for i = 1:run.trial_number
    
    trk = run.trial(i).trk;
    obj = trk.obj;
    
    if ~exist('obj_p_count','var')
        % DIM: M object types x N trials
        obj_p_count = NaN(size(run.obj_list,1),run.trial_number);
    end
    
    % Filter on objects encountered
    obj = obj(trk.obj_encountered);
    
    % Loop through objects
    tmp = [];
    for n = 1:length(obj)
        c = sum(p(:,i,2) <= obj(n).target_zone(1) ...
            &  p(:,i,2) >= obj(n).target_zone(2));
        tmp(n,1) = obj(n).code;
        tmp(n,2) = c;
    end
    
    for n = run.obj_list
        if ~isempty(tmp)
            ind = tmp(:,1) == n;
            enc_tmp = tmp(ind,2);
            if ~isempty(enc_tmp)
                obj_p_count(n,i) = mean(enc_tmp);
            else
                obj_p_count(n,i) = NaN;
            end
        else
            obj_p_count(n,i) = NaN; 
        end 
    end
end

run.obj_p_count = obj_p_count;

for i = 1:size(obj_p_count,1)
    tmp = obj_p_count(i,:);
    tmp(isnan(tmp)) = [];
    obj_p_count_median(i) = median(tmp);
end

run.obj_p_count_median = obj_p_count_median;

run.obj_p_count_sum = nansum(obj_p_count,2);


% run.obj_ftime = run.obj_count_sum/sum(run.obj_count_sum);
% run.obj_ftime_per_encounter = run.obj_ftime./run.obj_encounters_sum;





