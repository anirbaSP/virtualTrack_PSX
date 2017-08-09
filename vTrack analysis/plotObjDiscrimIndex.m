function plotObjDiscrimIndex(run,trials)
%
%
%
%
%

% Created: 6/30/12

function plotHoldTimePerObj(run,trials)
%
%
%
%

% Created: SRO - 6/28/12


if nargin < 2 || isempty(trials)
    trials = 1:size(run.position_data,2);
end

obj = run.obj_trk.obj;

for i = 1:length(obj)
    
    % Filter on trials
    t_ind = ismember(obj(i).trial,trials);
    obj(i).time_in_zone = obj(i).time_in_zone(t_ind);
    
    if datenum(run.date) < datenum('26-Jun-2012 10:00:00')
        tmp = obj(i).time_in_zone > run.trial(1).time_hold_for_reward*1.55;
    else
        tmp = obj(i).time_in_zone > run.trial(1).time_hold_for_reward;
    end
    f(i) = sum(tmp)/length(obj(i).time_in_zone);
    
end


% Objects
x = (1:length(f))';
x_label = 'Track objects';
xL = [min(x)-0.5 max(x)+0.5];

% Set y values
y = f';
y_err = zeros(size(y));  % Temp until adding code for CI
y = [y y_err y_err];
y_label = 'f';
yL = [0 max([max(max(y)); 1])];

% Figure setup
h.fig = portraitFigSetup;

% Define line properties
gray = [0.4 0.4 0.4];
l_color = {[0 0 0],gray,gray};
l_width = {1.5,1,1};

% Plot data probability of stopping in target zone
h.ax = axes('Parent',h.fig);
defaultAxes(h.ax,0.12,0.1,10);
for i = 1:size(y,2)
    if i == 1
        hline(i) = line('Parent',h.ax,'XData',x,'YData',y(:,i),...
            'Color',l_color{i},'LineWidth',l_width{i});
        %         set(hline(i),'MarkerFaceColor',l_color{i},'Marker','square',...
        %             'MarkerEdgeColor',l_color{i},'MarkerSize',4);
    else
        hline(i) = addErrBar2(x,y(:,1),y_err(:,1),y_err(:,2),'y',h.ax);
        set(hline(i),'Color',l_color{i});
    end
    
end

% Format axes
ylabel(y_label);
xlabel(x_label);
set(h.ax,'XLim',xL,'YLim',yL);

% Add track to plot
h.trk = makeTrkFig(run.obj_trk,gcf);

% Format axes
setAxes([h.trk.ax h.ax],4,2,[1 3],[],h.fig);

set(h.trk.ax,'Position',[0.0700 0.6583 0.4450 0.2038],'XDir','normal');
axis(h.trk.ax,'off');

a = 1;

