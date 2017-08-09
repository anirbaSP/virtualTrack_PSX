%% Analyze vTrack + physiology expt

%% Modify experiment table
rdef = RigDefs;
exptTable = 'SRO_2012-11-29_M83A_ExptTable.mat';
t = loadvar([rdef.Dir.Data exptTable]);

k = find(strcmp(t,'Probe angle'));
t(k,2) = {'0'};

k = find(strcmp(t,'Probe type'));
t(k,2) = {'16 Channel'};

k = find(strcmp(t,'Probe configuration'));
t(k,2) = {'1x16'};

% Add expt type
k = min(find(strcmp(t(:,1),'')));
t(k,1) = {'Experiment type'};
t(k,2) = {'vTrack'};

% Save table
save([rdef.Dir.Data exptTable],'t');

%% Investigate run struct

r = loadvar([rdef.Dir.vTrackData expt.runSweeps.run_file{1} '.mat']);

%% 
% Determine reference 'encounter_time' for each object
 obj = findTimeObjPosition(r);
 
% 
s = spikes;
s.sweeps = struct('fileInd',[],'trials',[],'trigger',[],'time',[],'stimcond',[]);
s = filtspikes(s,0,'assigns',[52]);
s = filtspikes(s,0,'assigns',[39]);
s = filtspikes(s,0,'assigns',[41 39]);

figure;
plotAvgSpikesPerObj(s,obj);
 
 %% Analyze SRO_2012_11_29_M83B
 
 % Load run file
 
 % Load spikes file
 
 
 
 
 
 
 
 
 
 
 
 
 
 