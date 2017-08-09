function displayRunTrial(h,trk,p,t,spikes_t_p)
%
% INPUT
%   h: Handles to figure, axes, etc.
%   
%

% 

set(h.fig,'Position',[-1195 302 1123 742])

% Display track
h.trk = makeTrkFig(trk,h.fig,h.trk.ax);
% set(h.trk.ax,'XDir','normal');

% Display position data
p = p*trk.screen_cm_per_pix; % Convert pixels to cm
set(h.run_p,'XData',p,'YData',t);
xlim([0 max(p)]);
ylim([0 max(t)]);

% Display spikes
spikes_t_p(:,2) = spikes_t_p(:,2)*trk.screen_cm_per_pix; 
set(h.spike,'XData', spikes_t_p(:,2),'YData', spikes_t_p(:,1));
a = 1;
