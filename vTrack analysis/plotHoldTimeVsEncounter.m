function h = plotHoldTimeVsEncounter(r,hFig)
%
%
%
%

% Created: SRO - 2/8/13



obj = r.obj_trk.obj;
holdTime = r.trial(1).time_hold_for_reward;
% factorPastHold = 2.5;
factorPastHold = 10;


for i = 1:length(obj)
    h.ax(i) = axes('Parent',hFig,'YDir','reverse');
    defaultAxes(h.ax(i));
    ylabel('Time (min)');
    tmp = obj(i).time_in_zone;
    tmp(tmp > factorPastHold*holdTime) = factorPastHold*holdTime;
    h.l(i) = line('XData',tmp,'YData',obj(i).encounter_time/60,...
        'LineStyle','none','Marker','o','Color',colors(i),...
        'MarkerSize',4);
    
    % Set xlim
    xlim([0 factorPastHold*holdTime*1.1]);
    
    % Set ylim
    tmp2 = {obj(:).encounter_time};
    tmp2 = cell2mat(tmp2);
    ylim([1 max(tmp2)/60]);
    
    % Add vertical line at hold time
    yL = get(h.ax(i),'YLim');
    x = r.trial(1).time_hold_for_reward;
    h.holdTime(i) = line('XData',[x x],'YData',[0 yL(2)],'Color',[0.7 0.7 0.7]);
    
end



