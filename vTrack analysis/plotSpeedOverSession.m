function h = plotSpeedOverSession(r,hFig)
%
%
%
%

% Created: SRO - 2/10/13


if nargin < 2 || isempty(hFig)
    hFig = figure;
end


% Make
pmat = r.position_data;
t = [];
p = [];
s = [];
for i = 1:length(r.trial)
    t = [t; pmat(:,i,1)+r.trial(i).start_time];
    p = [p; pmat(:,i,2)];
    s = [s; pmat(:,i,3)];
end

% Convert to units of cm/s
gain = r.trial(1).track_gain;
pixels_per_cm = r.pixels_per_cm;
s = s/gain/pixels_per_cm*(3/6);  % Last term (mouse loc on disk/size disk)

% Convert time to minutes
t = t/60;

% Plot all data points
h.ax = axes('Parent',hFig);
defaultAxes(h.ax)
h.l(1) = line('Parent',h.ax,'XData',t,'YData',s,'LineStyle','none','Marker','.',...
    'MarkerSize',1,'Color',[0.7 0.7 0.7]);

% Plot smoothed avg
span = 30*60 + 1; % Approximately 1 minute
s_smooth = smooth(s,span);
s_smooth(1:floor(span/4)) = NaN;
s_smooth(end-floor(span/4):end) = NaN;
h.l(2) = line('Parent',h.ax,'XData',t,'YData',s_smooth,'Color','k','LineWidth',2);

% Set xlim
xlim([0 max(t)]);

% Set ylim
ylim([-1 max(s)*0.85]);

ylabel('Running speed (cm/s)')





