function h = plotDprimeOverSession(r,hFig)
%
%
%
%

% Created: SRO - 2/10/13




if nargin < 2 || isempty(hFig)
    hFig = figure;
end


h.ax = axes('Parent',hFig);
defaultAxes(h.ax);

% Get all encounters
obj = r.obj_trk.obj;
enc_times = cell2mat({obj(:).encounter_time})/60;

binsize = 15;
edges = 0:binsize:max(enc_times)+binsize;
centers = edges + binsize/2;
centers(end) = [];


for i = 1:length(obj)
    
    % Yes, choice
    all_choices = obj(i).encounter_time/60;
    yes_choices = obj(i).encounter_time((obj(i).choice == 1))/60;
    
    c_all = histc(all_choices,edges);
    c_yes = histc(yes_choices,edges);
    tmp = c_yes./c_all;
    tmp(end) = [];
    p_yes(i,:) = tmp;
    
    if i > 1
        % Compute d-prime (zHit - zFA)
        hit = p_yes(1,:);    
        fa = p_yes(i,:);      
        hit(hit==1) = 0.99;
        hit(hit==0) = 0.01;
        fa(fa==1) = 0.99;
        fa(fa==0) = 0.01;
        
        d = norminv(hit) - norminv(fa);
        
        h.l(i) = line('Parent',h.ax,'XData',centers,'YData', d,...
            'Color',colors(i),'LineWidth',1.5);
        
    end
    
end

ylim([-0.2 4.8]); % max d-prime is 4.65 for hit = 0.99, fa = 0.01
xlim([0 (centers(end)+binsize/2)]);

ylabel('d-prime');

