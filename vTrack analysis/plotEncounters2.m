function plotEncounters2()
%
%
%

% Created: SRO 12/4/12


% **** Load tmp data **** %
rdef = RigDefs;
% 
% ---- 11/29
% expt = loadvar('S:\SRO DATA\Data\Expt\SRO_2012-11-29_M83B_expt');
% r = loadvar('\\132.239.203.44\Users\shawn\vTrack Data\SRO_2012-11-29_M83_RUN_2');
% mouse = loadvar('\\132.239.203.44\Users\shawn\Mouse Database\M83_Sep_2012_mouse');
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-29_M83B_T4_Ch_11_3_14_6_spikes_SD35']);
% assign = 44;
% assign = 65;
% % % assign = [52];
% 
% 
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-29_M83B_T1_Ch_16_8_15_7_spikes_SD4']);
% assign = [98];
% assign = [90];
% assign = [91];
% assign = [82 90 91 95];

% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-29_M83B_T2_Ch_12_4_13_5_spikes_SD4']);
% assign = 100;
% % assign = 115;
% 
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-29_M83B_T6_Ch_13_5_10_spikes_SD5']);
% assign = 88;

% ---- 11/30
% expt = loadvar('S:\SRO DATA\Data\Expt\SRO_2012-11-30_M83A_expt');
% r = loadvar('/Users/Shawn/Google Drive/M83 vTrack + physiology/SRO_2012-11-30_M83_RUN_1');
% r = loadvar('\\132.239.203.44\Users\shawn\vTrack Data\SRO_2012-11-30_M83_RUN_1');

r = loadvar('\\132.239.203.44\Users\shawn\vTrack Data\SRO_2012-11-30_M83_RUN_2');
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-30_M83C_T2_Ch_12_4_13_5_spikes_SD4']);
% assign = [8];

% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-30_M83C_T3_Ch_10_2_9_1_spikes_SD4']);
% % assign = [22];
% assign = [80];

stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-30_M83C_T4_Ch_11_3_14_6_spikes_SD4']);
assign = 31;



% mouse = loadvar('\\132.239.203.44\Users\shawn\Mouse Database\M83_Sep_2012_mouse');
p = r.position_data(:,:,2);
t = r.position_data(:,:,1);
% 
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-30_M83A_T2_Ch_12_4_13_5_spikes_SD3']);
% assign = [21];
% 
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-30_M83A_T6_Ch_9_1_11_spikes_SD35']);
% assign = [95];

% 
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-30_M83A_T3_Ch_10_2_9_1_spikes_SD4']);
% assign = [100];

% stmp = loadvar('S:\SRO DATA\Data\Spikes\SRO_2012-11-30_M83A_T5_Ch_2_9_1_spikes_SD3');
% assign = [100];


% stmp = loadvar('/Users/Shawn/Google Drive/M83 vTrack + physiology/SRO_2012-11-30_M83A_T4_Ch_11_3_14_6_spikes_SD4');
% stmp = loadvar('S:\SRO DATA\Data\Spikes\SRO_2012-11-30_M83A_T4_Ch_11_3_14_6_spikes_SD4');

% assign = 115;


stmp.sweeps = struct('fileInd',[],'trials',[],'trigger',[],'time',[],'stimcond',[]);

s = filtspikes(stmp,0,'assigns',assign);
% s = stmp;
clear stmp
s = rmfield(s,'waveforms');

% **** tmp data ***** %

total_encounters = {r.obj_trk.obj(:).trial};
total_encounters = length(cell2mat(total_encounters));
encounter_ind = 0;

trials = 1:size(r.position_data,2);
% Loop through trials
for i = 1:length(trials)
    
    trial_ind = trials(i);
    
    % Get track for current trial
    trk = r.trial(trial_ind).trk;
    obj = trk.obj;
    
    % Filter on objects encountered
    obj = obj(trk.obj_encountered);
    
    % Loop through objects encountered
    for n = 1:length(obj)
        
        encounter_ind = encounter_ind + 1;
        % Get code for this object
        tmp_obj_code = obj(n).code;
        encounter(encounter_ind).obj_code = tmp_obj_code;
        
        % Extract position data
        k = p(:,trial_ind) < obj(n).panel_right + 2900*2 & p(:,trial_ind) > obj(n).panel_left - 2900*2 ;
        encounter(encounter_ind).position = p(k,trial_ind);
         % Make position relative to tile
        encounter(encounter_ind).position = encounter(encounter_ind).position - obj(n).panel_left;
        
        % Extract time data
        encounter(encounter_ind).time =  t(k,trial_ind);
        
        % Extract spike time and position data
        if ~isempty(encounter(encounter_ind).position)
            s_thisTrial = filtspikes(s,0,'trials',trial_ind);
            tmp_spiketimes = s_thisTrial.spiketimes;
            tmp_spiketimes = tmp_spiketimes(tmp_spiketimes >= encounter(encounter_ind).time(1) ...
                & tmp_spiketimes <= encounter(encounter_ind).time(end));
            spikes_t_p = mapSpiketimeToPosition(tmp_spiketimes,encounter(encounter_ind).position,encounter(encounter_ind).time);
            encounter(encounter_ind).spiketimes = spikes_t_p(:,1);
            encounter(encounter_ind).spikeposition = spikes_t_p(:,2);
        else
            encounter(encounter_ind).spiketimes = [];
            encounter(encounter_ind).spikeposition = [];
        end
        a = 1;

    end
end

a = 1;

obj_types = cell2mat({encounter(:).obj_code});
edges = linspace(0,2900,50);
for i = 1:length(r.obj_trk.obj)
    k = obj_types == i;
    tmp_enc = encounter(k);
    tmp_pos = cell2mat({tmp_enc(:).position}');
    tmp_pos = histc(tmp_pos,edges);
    tmp_spikepos = cell2mat({tmp_enc(:).spikeposition}');
    tmp_spikepos = histc(tmp_spikepos,edges);
    
    % compute rate
    tmp_spikepos = tmp_spikepos(1:end-1)';
    tmp_pos = tmp_pos(1:end-1)';
    s_rate(:,i) = tmp_spikepos./tmp_pos*30;
%         s_rate(:,i) = tmp_spikepos./sum(tmp_pos)*30;
    s_rate(:,i) = smooth(s_rate(:,i),5);
    a = 1;
    
    % Find time at center of RF
    rf_center = 1650;
    t_window = [-4 4];
    
       spikes.spiketimes = [];
        spikes.spikeposition = [];
        spikes.trials = [];
    for n = 1:length(tmp_enc)
        a =1 ;
        % Find time reaching reference point
        tmp = diff(tmp_enc(n).position > rf_center);
        k = find(tmp == -1);
        k = min(k);
        t_enc = tmp_enc(n).time(k+1);
        % Get spikes in window around reference point
        k = tmp_enc(n).spiketimes > t_enc + t_window(1) ...
            & tmp_enc(n).spiketimes < t_enc+ t_window(2);
        tmp_spiketimes = tmp_enc(n).spiketimes(k) - t_enc; 
        tmp_spikeposition = tmp_enc(n).spikeposition(k);
        a = 1;
        spikes.spiketimes = [spikes.spiketimes tmp_spiketimes'];
        spikes.spikeposition = [spikes.spikeposition tmp_spikeposition'];
        spikes.trials = [spikes.trials n*ones(1,length(tmp_spiketimes))];
    end
    spikes.sweeps.trials = 1:length(tmp_enc);
    spikes.info.detect.dur = sum(abs(t_window));
    spikes.info.time_window = t_window;
    figure('Position',[80    37   560   420]); 
    raster(spikes);
    a = 1;
    
end

% Compute center of bins
centers = edges + diff(edges(1:2))/2;

% Output (Remove last point, which contains values that fall directly on
% edge of last bin)
centers = (centers(1:end-1))';


% Plot data
a = 1;
 figure; plot(centers,s_rate)
 
 
 



