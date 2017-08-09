% vTrack + ephys 
% SRO - 2/14/13



%% Make raster and histogram of spikes vs position

% Load spikes struct
s = loadvar();

% Filter on unit (or use multiple units)
s = spikes;
s.sweeps = struct('fileInd',[],'trials',[],'trigger',[],'time',[],'stimcond',[]);

s = filtspikes(s,0,'assigns',65);
s = filtspikes(s,0,'assigns',100);



% Load run struct
r = loadvar();

% Map spike times to position
s = mapSpikeTimesToPosition(s,r);


% Raster
for i = 1:6
    tmp = filtspikes(s,0,'obj_type',i);
figure; pRaster(s);

end


% PSTH
for i = 1:6
    tmp = filtspikes(s,0,'obj_type',i);
figure; hist(tmp.position_rel,20)

end



%%



%%