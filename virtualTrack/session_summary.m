function session_summary(r,f_save)
%
% INPUT
%   r: Run struct
%
%
%

% Created: SRO - 2/4/13

if nargin < 2
    f_save = 0;
end


% --- Set some variables
obj = r.obj_trk.obj;
saveTag = [r.name '_forage_session'];

% --- Figure setup
h.fig = landscapeFigSetup;
setappdata(h.fig,'figText',saveTag);
addSaveFigTool(h.fig)
% set(h.fig,'Position',[792 399 1056 724])
set(h.fig,'Position',[-1182         305        1123         742],...
    'Visible','off')

% set(h.fig,'Visible','on')



% --- Experiment information
position = [0.643 0 0.271 0.177];  % [x y w h];
exptInfo = getExptInfo(r);
h.exptInfo = annotation('textbox',position,'String',exptInfo,...
    'EdgeColor','none','HorizontalAlignment','left','Interpreter',...
    'none','Color',[0.1 0.1 0.1],'FontSize',8,'FitBoxToText','on');

% --- Plot probability of stopping vs object
tmp = plotHoldTimePerObj(r,[],h.fig);
% delete(tmp.trk.ax);
tmp_pos = get(tmp.trk.ax,'Position');
set(tmp.trk.ax,'Position',[0.07 0.835 tmp_pos(3) tmp_pos(4)]);

% Format plots
params.matpos = [0.05 0.76 0.55 0.18];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.01 0 0];    % [L R T B]
setaxesOnaxesmatrix(tmp.ax,1,3,1:length(tmp.ax),params)

% --- Histogram hold times for each object (plot session in quarters)
tmp = plotHoldTimeVsEncounter(r,h.fig);
tmp2 = holdTimeHist(r,0.10,10);
removeAxesLabels(tmp.ax(2:end));
removeAxesLabels(tmp2.ax(2:end));
xlabel(tmp2.ax(1),'Hold time (s)');
ylabel(tmp2.ax(1),'f');


% Format plots
params.matpos = [0.05 0.45 0.55 0.18];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.01 0 0];    % [L R T B]
setaxesOnaxesmatrix(tmp.ax,1,length(tmp.ax),1:length(tmp.ax),params)

params.matpos = [0.05 0.64 0.55 0.075];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.01 0 0];    % [L R T B]
setaxesOnaxesmatrix(tmp2.ax,1,length(tmp2.ax),1:length(tmp2.ax),params)

% ax_width2 = ax_width/length(obj)*0.9;
% for i = 1:length(obj)
%     xpos = ax_left + (i-1)*ax_width/length(obj)*1.05;
%     set(tmp.ax(i),'Position',[xpos 0.465 ax_width2 0.2]);
%     set(tmp.ax(i),'YTickLabel',[],'XTickLabel',[]);
%
%     set(tmp2.ax(i),'Position',[xpos 0.35 ax_width2 0.1]);
%     set(tmp2.ax(i),'YTickLabel',[]);
% end
a = 1;


% --- Behavior raster
tmp = behaviorRaster(r,h.fig);
set(tmp.ax,'Position',[0.6527    0.7507    0.3054    0.1550]);


% --- Plot object position and velocity trajectory
tmp = plotObjTracjectory(r,h.fig);
% Format t vs p graphs
defaultAxes(tmp.p.ax);
defaultAxes(tmp.v.ax);
removeAxesLabels(tmp.p.ax(2:end));
removeAxesLabels(tmp.v.ax(2:end));
ylabel(tmp.p.ax(1),'Time (s)');
ylabel(tmp.v.ax(1),'Speed (cm/s)');
xlabel(tmp.v.ax(1),'Position');



params.matpos = [0.05 0.1 0.55 0.15];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.005 0 0];    % [L R T B]
setaxesOnaxesmatrix(tmp.p.ax,1,length(tmp.p.ax),1:length(tmp.p.ax),params)

% Format v vs p graphs
params.matpos = [0.05 0.26 0.55 0.15];
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.005 0 0];
setaxesOnaxesmatrix(tmp.v.ax,1,length(tmp.v.ax),1:length(tmp.v.ax),params)

% 
% 
% % Plot velocity vs time (aligned to object entry)
% a = 1;
% tmp = plotSpeedAlignedToEntry(r,h.fig);
% % Format v vs p graphs
% params.matpos = [0.05 0.26 0.55 0.15];
% params.figmargin = [0 0 0 0];
% params.matmargin = [0 0 0 0];
% params.cellmargin = [0 0.005 0 0];
% setaxesOnaxesmatrix(tmp.v.ax,1,length(tmp.v.ax),1:length(tmp.v.ax),params)



tmp = [];
tmp_ax = [];
% Plot stop rate over session
tmp = plotChoiceRate(r,h.fig);
tmp_ax(end+1) = tmp.ax(1);

% d-prime
tmp = plotDprimeOverSession(r,h.fig);
tmp_ax(end+1) = tmp.ax;


% Plot reward rate over session
tmp = plotRewardRateOverSession(r,h.fig);
tmp_ax(end+1) = tmp.ax(1);
delete(tmp.ax(2));

% --- Plot running speed over session
tmp = plotSpeedOverSession(r,h.fig);
tmp_ax(end+1) = tmp.ax;

% --- Plot cumulative rewards versus time
tmp = plotCumulativeRewardsVsTime(r,h.fig);
tmp_ax(end+1) = tmp.ax;


xLim = get(tmp_ax(4),'XLim');
set(tmp_ax,'XLim',xLim);



params.matpos = [0.65 0.25 0.33 0.52];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.03 0.03 0];    % [L R T B]
setaxesOnaxesmatrix(tmp_ax,3,2,1:length(tmp_ax),params)

% Make figure visible
a = 1;



% Save
rdef = RigDefs;
if f_save
    sdir = [rdef.Dir.Fig r.mouse_code ' ' 'Foraging Sessions' '\'];
    if ~isdir(sdir)
        mkdir(sdir);
    end
    sname = [sdir saveTag];
    disp(['Saving' ' ' sname])
    saveas(h.fig,sname,'pdf')
    saveas(h.fig,sname,'fig')
    saveas(h.fig,sname,'epsc')
    temp = sname;
    export_fig temp
end

% Close
if f_save
    set(h.fig,'Visible','on')
    close(h.fig)
else
    set(h.fig,'Visible','on')
end




function exptInfo = getExptInfo(r)
a = 1;


% Run file name
exptInfo{1,:} = r.name;

% Session duration
if isfield(r,'session_end_time');
    duration = etime(datevec(r.session_end_time),datevec(r.session_start_time))/60;
else
    duration = r.trial(1).trial_duration * r.trial_number;
end
exptInfo{2,:} = ['Duration:' ' ' ...
    num2str(duration,3) ...
    ' ' 'min'];

% Running
distance = r.trial(1).track_gain*r.distance/r.pixels_per_cm/100;
gain = r.trial(1).track_gain;
pixels_per_cm = r.pixels_per_cm;
speed = nanmean(nanmean(r.position_data(:,:,3)))/gain/pixels_per_cm*(3/6);

exptInfo{3,:} = ['Running:' ' ' ...
    num2str(distance,3) ...
    ' ' 'm,' ' ' ...
    num2str(speed,2) ...
    ' ' 'cm/s'];


% Reward parameters
exptInfo{4,:} = ['Reward params:' ' ' ...
    'Hold time =' ' ' ...
    num2str(r.trial(1).time_hold_for_reward) ' s'...
    ',' ' ' ...
    num2str(r.trial(1).reward_volume)...
    ' uL'];

% Reward volume and rate
exptInfo{5,:} = ['Rewards:' ' ' ...
    num2str(r.n_rewards) ...
    ',' ' ' ...
    num2str(r.n_rewards/duration,2) ...
    '/min,' ' ' ...
    ' ' ...
    num2str(r.trial(1).reward_volume*r.n_rewards/1000,2)...
    ' mL'];

% Object encounters
for i = 1:length(r.obj_trk.obj)
    encounters(i) = length(r.obj_trk.obj(i).trial);
end
exptInfo{6,:} = ['Encounters:' ' ' ...
    num2str(sum(encounters)) ...
    ',' ' ' ...
    num2str(sum(encounters)/duration,2) ...
    '/min,' ' ' ...
    'Obj = [' ...
    num2str((encounters)) ...
    ']'];



exptInfo = exptInfo';




