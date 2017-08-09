function h = plotObjTracjectory(r,hFig)
%
%
%
%

% Created: SRO - 2/10/13



if nargin < 2 || isempty(hFig)
    hFig = figure;
end

t_window = 4;
samples = round(4*r.track_update_frequency);
samples = round(4*20); % Kluge (effective update rate is ~20 Hz; vTrack needs work)
gain = r.trial(1).track_gain;
pixels_per_cm = r.pixels_per_cm;

obj = r.obj_trk.obj;
t = r.position_data(:,:,1);
p = r.position_data(:,:,2);
v = r.position_data(:,:,3);

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
            p_tmp = p(entry_ind:entry_ind+samples,trial);
            p_tmp = abs(p_tmp - max(p_tmp));
            p_tmp = p_tmp - r.trial(trial).trk.screen_width_pix/2 ...
                - r.trial(trial).trk.obj(i).size; % Align to object center
            t_tmp = t(entry_ind:entry_ind+samples,trial);
            t_tmp = t_tmp - min(t_tmp);
            v_tmp = v(entry_ind:entry_ind+samples,trial);
            
            avg_p(:,end+1) = p_tmp;
            avg_t(:,end+1) = t_tmp;
            
            % Plot position
            h.p.l(i,n) = line('Parent',h.p.ax(i),'XData',p_tmp,...
                'YData',t_tmp,'LineWidth',0.75,'Color',[0.8 0.8 0.8]);
            
            % Plot velocity
            edges = - r.trial(trial).trk.screen_width_pix/2 ...
                - r.trial(trial).trk.obj(i).size;
            n_bins = 20;
            edges = linspace(edges,r.trial(trial).trk.obj(i).size,n_bins+1);
            centers = edges(1:end-1) + diff(edges(1:2))/2;
            v_tmp = smooth(v_tmp,3);
            v_tmp = v_tmp/gain/pixels_per_cm*(3/6);
            
            for i_bin = 1:(length(edges)-1)
                % Get position index
                p_index = (p_tmp >= edges(i_bin)) & (p_tmp < edges(i_bin+1));
                v_bins(i_bin) = mean(v_tmp(p_index));
            end
            avg_v(:,end+1) = v_bins;
            h.v.l(i,n) = line('Parent',h.v.ax(i),'XData',centers,...
                'YData',v_bins,'LineWidth',0.75,'Color',[0.8 0.8 0.8]);
        end
    end
    
    % Position
    % Strange issue of positions > 1000 (wrap around track?)
    avg_p(avg_p > 10000) = NaN;
    avg_t(avg_p > 10000) = NaN;
    avg_p(:,i) = nanmean(avg_p,2);
    avg_t(:,i) = nanmean(avg_t,2);
    h.p.avg(i) = line('Parent',h.p.ax(i),'XData',avg_p(:,i),...
        'YData',avg_t(:,i),'LineWidth',2,'Color',colors(i));
    xlim([min(min(avg_p)) r.trial(1).trk.screen_width_pix/2]);
    
    % Velocity
    avg_v(:,i) = nanmean(avg_v,2);
    h.v.avg(i) = line('Parent',h.v.ax(i),'XData',centers,...
        'YData',avg_v(:,i),'LineWidth',2,'Color',colors(i));
    a = 1;
end

% Plot overlay of averages
h.p.ax(end+1) = axes('Parent',hFig);
h.v.ax(end+1) = axes('Parent',hFig);
for i = 1:length(obj)
    x = get(h.p.avg(i),'XData');
    y = get(h.p.avg(i),'YData');
    h.p.avg_overlay(i) = line('Parent',h.p.ax(end),'XData',x,...
        'YData',y,'LineWidth',2,'Color',colors(i));
    
     x = get(h.v.avg(i),'XData');
    y = get(h.v.avg(i),'YData');
    h.v.avg_overlay(i) = line('Parent',h.v.ax(end),'XData',x,...
        'YData',y,'LineWidth',2,'Color',colors(i));
end


% Set limits
x_entry = -r.trial(1).trk.screen_width_pix/2 - r.trial(1).trk.obj(1).size;
x_size = r.trial(1).trk.obj(1).size;
set(h.p.ax,'YLim',[0 4],'XLim',[x_entry x_size]);
set(h.v.ax,'YLim',[-1 max(max(avg_v))],'XLim',[x_entry x_size]);








%
%
%
%
% function plotObjTracjectory(r,hFig)
% %
% %
% %
% %
%
% % Created: SRO - 2/10/13
%
%
%
% if nargin < 2 || isempty(hFig)
%     hFig = figure;
% end
%
% t_window = 4;
% samples = round(4*r.track_update_frequency/2);
% samples = round(4*20/2); % Kluge (effective update rate is ~20 Hz; vTrack needs work)
%
% obj = r.obj_trk.obj;
% t = r.position_data(:,:,1);
% p = r.position_data(:,:,2);
% v = r.position_data(:,:,3);
%
%
% for i = 1:length(obj)
%
%     h.ax(i) = axes('Parent',hFig,'XDir','reverse');
%
%     avg_p = [];
%     avg_t = [];
%     for n = 1:length(obj(i).encounter_time)
%         % This object
%         p_data_ind = obj(i).position_data_ind(n);
%         center = obj(i).obj_centers(n);
%         encounter_time = obj(i).encounter_time(n);
%         trial = obj(i).trial(n);
%
%         % Set data
%         trial_start_time = r.trial(trial).start_time;
%         if p_data_ind <= samples || (p_data_ind+samples >= length(p(:,trial)))
%             skip = 1;
%         else
%             skip = 0;
%         end
%         if ~skip
%             p_tmp = p(p_data_ind-samples:p_data_ind+samples,trial);
%             p_tmp = p_tmp - center;
%             t_tmp = t(p_data_ind-samples:p_data_ind+samples,trial);
%             t_tmp = t_tmp - encounter_time + trial_start_time;
%
%             avg_p(:,end+1) = p_tmp;
%             avg_t(:,end+1) = t_tmp;
%
%             % Plot
%             h.l(i,n) = line('Parent',h.ax(i),'XData',p_tmp,...
%                 'YData',t_tmp,'LineWidth',0.75,'Color',[0.8 0.8 0.8]);
%         end
%     end
%
%     avg_p = mean(avg_p,2);
%     avg_t = mean(avg_t,2);
%     h.avg(i) = line('Parent',h.ax(i),'XData',avg_p,...
%         'YData',avg_t,'LineWidth',2,'Color',colors(i));
%     a = 1;
% end
%
%
