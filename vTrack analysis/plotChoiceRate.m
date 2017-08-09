function h = plotChoiceRate(r,hFig)
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
    p_yes = c_yes./c_all;
    p_yes(end) = [];
    
    h.l(i) = line('Parent',h.ax,'XData',centers,'YData',p_yes,...
        'Color',colors(i),'LineWidth',1.5);
    
end

ylim([-0.1 1.1]);
xlim([0 (centers(end)+binsize/2)]);

ylabel('Yes choices');

