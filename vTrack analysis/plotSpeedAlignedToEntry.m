function h = plotSpeedAlignedToEntry(r,hFig)
%
%
%
%

% Created: SRO - 2/24/13



a = 1;




if nargin < 2 || isempty(hFig)
    hFig = figure;
end


samples = round(4*r.track_update_frequency);
samples = round(4*20); % Kluge (effective update rate is ~20 Hz; vTrack needs work)
gain = r.trial(1).track_gain;
pixels_per_cm = r.pixels_per_cm;

obj = r.obj_trk.obj;
t = r.position_data(:,:,1);
p = r.position_data(:,:,2);
v = r.position_data(:,:,3);

time_range = 1.2;
edges = 0:0.05:time_range;

t_tmp = 0:1/20:time_range;

for i = 1:length(obj)
    
    h.p.ax(i) = axes('Parent',hFig);
    h.v.ax(i) = axes('Parent',hFig);
    
    avg_p = [];
    avg_t = [];
    avg_v = [];
    
    for n = 1:length(obj(i).encounter_time)
        % This object
        entry_ind = obj(i).entry_ind(n);
        trial = obj(i).trial(n);

        % Set data
        if entry_ind + samples > length(p(:,trial))
            skip = 1;
        else
            skip = 0;
        end
        
        if ~skip
            tmp_ind = entry_ind:1:(entry_ind) + time_range*20;
%             entry_time = t(entry_ind,trial);
%             tmp_ind = t(:,trial) >= entry_time & t(:,trial) <= entry_time + time_range;
            
            % Get zeroed time values
            v_tmp = v(tmp_ind,trial);
            v_tmp = v_tmp/gain/pixels_per_cm*(3/6);
            
            % Plot position
            h.v.l(i,n) = line('Parent',h.v.ax(i),'XData',t_tmp,...
                'YData',v_tmp,'LineWidth',0.75,'Color',[0.8 0.8 0.8]);
        end
        
            avg_v(:,n) = v_tmp;
        
    end
    
    % Velocity
    avg_v(:,i) = nanmean(avg_v,2);
    h.v.avg(i) = line('Parent',h.v.ax(i),'XData',t_tmp,...
        'YData',avg_v(:,i),'LineWidth',2,'Color',colors(i));
  
    a = 1;
end

% Plot overlay of averages
h.v.ax(end+1) = axes('Parent',hFig);
for i = 1:length(obj)
    
    x = get(h.v.avg(i),'XData');
    y = get(h.v.avg(i),'YData');
    h.v.avg_overlay(i) = line('Parent',h.v.ax(end),'XData',x,...
    'YData',y,'LineWidth',2,'Color',colors(i));
 end


% Set limits

set(h.v.ax,'YLim',[-1 max(max(avg_v))],'XLim',[-0.05 time_range]);

