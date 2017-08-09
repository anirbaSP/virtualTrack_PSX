function run = computeObjTrkHist(run,n_bins,n_bins_t)
%
%
%
%
%

% Created: SRO - 6/22/12

if nargin < 2 || isempty(n_bins)
    n_bins = 20;
end

if nargin < 3 || isempty(n_bins_t)
    n_bins_t = 40;
end

% Get position, velocity, and acceleration data and set rest periods to NaN
p = run.position_data;
rest = logical(p(:,:,5));
for i = 1:4
    tmp = p(:,:,i);
    tmp(rest) = NaN;
    p(:,:,i) = tmp;
end

pmat = p;
p = pmat(:,:,2);
t = pmat(:,:,1);
v = pmat(:,:,3);
v(v < -200) = NaN;
a = pmat(:,:,4);
a(abs(a) > 4000) = NaN;


% Set position histogram bins (relative to center of object)
hist_range = run.obj_trk.object_size/2 + run.obj_trk.object_spacing;
run.obj_trk.p_hist_edges = linspace(-hist_range,hist_range,n_bins+1);
run.obj_trk.p_hist_centers = diff(run.obj_trk.p_hist_edges)/2 ...
    + run.obj_trk.p_hist_edges(1:end-1);

% Set time histogram bins (t = 0 when object first enters reward zone)
n_bins_t = 40;
hist_range_t = 1;
run.obj_trk.t_hist_edges = linspace(-hist_range_t/2,hist_range_t/2,n_bins_t+1);
run.obj_trk.t_hist_centers = diff(run.obj_trk.t_hist_edges)/2 ...
    + run.obj_trk.t_hist_edges(1:end-1);


fld = {'trial','reward','p_histc','tp_counts','vp_counts','ap_counts',...
    'vt_counts','at_counts'};
for i = 1:length(fld)
    if isfield(run.obj_trk.obj,fld{i})
        run.obj_trk.obj = rmfield(run.obj_trk.obj,fld{i});
    end
    run.obj_trk.obj(1).(fld{i}) = [];
end

% Loop through trials
for i = 1:run.trial_number
    
    % Get track for current trial
    trk = run.trial(i).trk;
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
        
        % Set position edges for this object
        tmp_edges = run.obj_trk.p_hist_edges + obj(n).center;
        c = histc(p(:,i),tmp_edges);
        run.obj_trk.obj(tmp_obj_code).p_histc(end+1,:) = c(1:end-1);
        
        % Loop on edges (** increase efficiency of code)
        obj_ind = size(run.obj_trk.obj(tmp_obj_code).tp_counts,1)+1;
        for e_ind = 1:length(tmp_edges)-1
            
            % Find indices of position values
            k = p(:,i) >= tmp_edges(e_ind) & p(:,i) < tmp_edges(e_ind+1);
            
            % Set time (samples) counts
            run.obj_trk.obj(tmp_obj_code).tp_counts(obj_ind,e_ind) = sum(k);
            
            % Set velocity counts
            run.obj_trk.obj(tmp_obj_code).vp_counts(obj_ind,e_ind) = nanmean(v(k,i));
            
            % Set acceleration counts
            run.obj_trk.obj(tmp_obj_code).ap_counts(obj_ind,e_ind) = nanmean(a(k,i));
        end
         
        % Set time edges for this object
        
        % Find time that object enters reward zone
        
       
    end
end

a = 1;
