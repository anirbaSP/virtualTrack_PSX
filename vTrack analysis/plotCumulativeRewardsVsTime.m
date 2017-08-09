function h = plotCumulativeRewardsVsTime(r,hFig)
%
%
%
%
%

% Created: SRO - 2/8/13


reward = r.reward_data;

h.ax = axes('Parent',hFig);
defaultAxes(h.ax);

t = {reward.time_in_session};
t = cell2mat(t);
t = t/60;
h.line = line('XData',t,'YData',1:length(t));

xlabel('Time (min)');
ylabel('Rewards');

ylim([0 length(t)]);