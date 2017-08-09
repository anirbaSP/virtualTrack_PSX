function h = behaviorRaster(r,hFig)
%
%
%
%
%

% Created: SRO - 2/9/13




h.ax = axes('Parent',hFig);
set(h.ax,'YDir','reverse');
defaultAxes(h.ax);

% Set variables
obj = r.obj_trk.obj;
y_ind = 0;

% Compute x limits
xLim = {obj(:).encounter_time};
xLim = max(cell2mat(xLim));

for i = 1:length(obj)
    
    % Yes, choice
    y_ind = y_ind + 1;
    x = obj(i).encounter_time((obj(i).choice == 1));
    y = y_ind*ones(size(x));
    if ~isempty(y)
        h.l(i,1) = linecustommarker(x/60,y);
    else
        h.l(i,1) = line('XData',[],'YData',[]);
    end
    if i == 1
        set(h.l(i,1),'Color','k','LineWidth',1);
    else
        set(h.l(i,1),'Color','r','LineWidth',1);
    end
    
    % No, choice
    y_ind = y_ind + 1;
    x = obj(i).encounter_time((obj(i).choice == 0));
    y = y_ind*ones(size(x));
    if ~isempty(y)
        h.l(i,2) = linecustommarker(x/60,y);
    else
        h.l(i,2) = line('XData',[],'YData',[]);
    end
    if i > 1
        set(h.l(i,2),'Color','k','LineWidth',1);
    else
        set(h.l(i,2),'Color','r','LineWidth',1);
    end
    
    %     h.l(i,1) = line('Parent',h.ax,'XData',x,'YData',y,'LineStyle','none',...
    %         'Marker','o','Color',colors(i));
    
    y_ind = y_ind+1;
    % Separator line
    line('Parent',h.ax,'XData',[-0.5 xLim],'YData',[y_ind-0.2 y_ind-0.2],'Color',colors(i),...
        'LineWidth',1);
    
end

% Set xlim
xlim([-0.5 max(xLim)/60]);

% Set yLim
ylim([0 y_ind+1])
