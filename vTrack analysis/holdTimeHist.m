function h = holdTimeHist(r,binsize,range)
%
% INPUT
%   r: run struct
%   binsize: ms
%

% Created: SRO - 2/5/13

if nargin < 2 || isempty(binsize)
    binsize = 0.05;
end

if nargin < 3 || isempty(range)
    range = 3*r.trial(1).time_hold_for_reward;
end

if nargin < 4 || isempty(obj_ind)
    obj_ind = 1:length(r.obj_trk.obj);
end

obj = r.obj_trk.obj;
holdTime = r.trial(1).time_hold_for_reward;

% Make bins
bins = 0:binsize:range;

% Make histogram of hold times for each object
for i = 1:length(obj)
    tmp = obj(i).time_in_zone;
    tmp(tmp > range) = range;
    c(:,i) = histc(tmp,bins);
    
    % Compute fraction encounters
    c(:,i) = c(:,i)./sum(c(:,i));
end


% Computer centers
centers = bins(1:end) + binsize/2;
centers(end) = range;

% Find max of non-target
y_max = max(max(c(:,2:end)));

% Make figure
for i = 1:size(c,2)
    h.ax(i) = axes;
    defaultAxes(h.ax(i));
    xlabel('Hold time (s)');
    ylabel('f');
    h.hist(i) = bar(h.ax(i),centers',c(:,i));
    set(h.hist(i),'FaceColor',colors(i),'EdgeColor',colors(i),'BarWidth',1);
    
    % Add vertical line at hold time
    yL = get(h.ax(i),'YLim');
    x = holdTime;
    h.holdTime = line('XData',[x x],'YData',[0 yL(2)],'Color',[0.7 0.7 0.7]);
    
    % Set xLim
    xlim([0 range*holdTime*1.1]);
    ylim([0 y_max]);
end
%
set(h.ax,'Box','off');



