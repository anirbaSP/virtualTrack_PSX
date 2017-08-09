function runViewer()
%
%
%
%

% Created: SRO 12/2/12


% **** Load tmp data **** %
rdef = RigDefs;
expt = loadvar('S:\SRO DATA\Data\Expt\SRO_2012-11-29_M83B_expt');
r = loadvar('\\132.239.203.44\Users\shawn\vTrack Data\SRO_2012-11-29_M83_RUN_2');
mouse = loadvar('\\132.239.203.44\Users\shawn\Mouse Database\M83_Sep_2012_mouse');

stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-29_M83B_T4_Ch_11_3_14_6_spikes_SD5']);
assign = [39 41 52];
assign = [39];

 
% stmp = loadvar([rdef.Dir.Spikes 'SRO_2012-11-29_M83B_T1_Ch_16_8_15_7_spikes_SD4']);
% assign = [98 90 91];

stmp.sweeps = struct('fileInd',[],'trials',[],'trigger',[],'time',[],'stimcond',[]);

for i = 1:length(assign)
    s(i) = filtspikes(stmp,0,'assigns',assign(i));
end
s = filtspikes(stmp,0,'assigns',assign);
clear stmp
s = rmfield(s,'waveforms');

% **** tmp data ***** %

% Make figure
h.fig = landscapeFigSetup;
set(h.fig,'Position',[413 317 1123 742]);

% % Add forward/back buttons
% h.f_button = uicontrol('Style','pushbutton');
% h.b_button = uicontrol('Style','pushbutton');

% Axis for displaying track
h.trk.ax = axes('Parent',h.fig);
set(h.trk.ax,'Position',[0.1291    0.6504    0.8210   0.15951]);
% h.trk = makeTrkFig(trk,hfig,hax,scale_im);

% Axis for displaying data
h.ax = axes('Parent',h.fig);
defaultAxes(h.ax);
ylabel('time (s)');
set(h.ax,'Position',[0.1291    0.0782    0.8210    0.5431]);
set(h.ax,'XDir','reverse')

% Line for run data
h.run_p = line('Parent',h.ax);

% Line for spike data
h.spike = line('Parent',h.ax,'LineStyle','none','Marker','+');


% Extract trk and run data
a = 1;
trial = 7;
trk = r.trial(trial).trk;
p = r.position_data(:,trial,2);
t = r.position_data(:,trial,1);

% Extract spikes for trial
s_tmp = filtspikes(s,0,'trials',1);
spikes_t_p = mapSpiketimeToPosition(s_tmp.spiketimes,p,t);
displayRunTrial(h,trk,p,t,spikes_t_p)



% Plot spikes







