function h = plotRewardRateOverSession(r,hFig)
%
%
%
%

% Created: SRO - 2/10/13


if nargin < 2 || isempty(hFig)
    hFig = figure;
end


r_times = cell2mat({r.reward_data(:).time_in_session});
r_times = r_times/60;

binsize = 15;
edges = 0:binsize:max(r_times)+binsize;
centers = edges + binsize/2;
centers(end) = [];

r_rate = histc(r_times,edges);
r_rate(end) = [];
r_rate = r_rate/binsize;

% Make plot
h.ax(1) = axes('Parent',hFig);
defaultAxes(h.ax(1));

h.l(1) = line('Parent',h.ax,'XData',centers,'YData',r_rate,'LineWidth',2);
ylabel('Reward/min');
yLim = [0 max(r_rate)*1.1];
ylim(yLim);
xLim = [0 max(centers)+binsize/2];
xlim(xLim);


h.ax(2) = axes('Parent',hFig);
defaultAxes(h.ax(2));
set(h.ax(2),'YAxisLocation','right','Color','none');
yLim = yLim*r.trial(1).reward_volume;
ylim(yLim);
xlim(xLim);





a = 1;