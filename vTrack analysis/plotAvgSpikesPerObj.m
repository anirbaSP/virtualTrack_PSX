function plotAvgSpikesPerObj(spikes,obj)
%
%
%
%

% Created: SRO - 10/11/12



% Extract spikes for each encounter
spikes.sweeps = struct('fileInd',[],'trials',[],'trigger',[],'time',[],'stimcond',[]);
maxObj = 0;
for n = 1:length(obj)
    maxObj = max([maxObj length(obj(n).trial)]);
end

spikesPerEncounter = NaN(maxObj,length(obj));
for n = 1:length(obj)
    for i = 1:length(obj(n).encounter_time)
        s =  filtspikes(spikes,0,'trials',obj(n).trial(i));
        s_tmp(i) = filtspikesTime(s,obj(n).encounter_time(i)+[-1 0.25]);
        spikesPerEncounter(i,n) = length(s_tmp(i).spiketimes);
        
    end
end
a = 1;

m = nanmean(spikesPerEncounter);
plot(m)