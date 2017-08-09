function hax = plotObjTrkHist(run,x_type,y_type,hfig,hax,n_bins,n_bins_t,useCmap)
%
%
%
%

% Created: SRO - 6/22/12


if nargin < 2 || isempty(x_type)
    x_type = 'p';
end

if nargin < 3 || isempty(y_type)
    y_type = 't';
end

if nargin < 4 || isempty(hfig)
    %hfig = portraitFigSetup;
    hfig=figure;
end

if nargin < 5 || isempty(hax)
    % Make axis for histogram data
    hax = axes('Parent',hfig);
    defaultAxes(hax,0.32,0.043);
end

if nargin < 6 || isempty(n_bins)
    n_bins = 20;
end

if nargin < 7 || isempty(n_bins_t)
    n_bins_t = 40;
end

if nargin < 8 || isempty(useCmap)
    useCmap = 0;
end

x_str = {'Position (cm)','Time (s)'};
y_str = {'Time','Velocity (cm/s)','Acceleration (cm/s^2)'};

fld = [y_type x_type '_counts'];

% Temp
type = 'mean';

obj = run.obj_trk.obj;
trk = run.obj_trk;
obj_order = trk.obj_list;  % TO DO: Add functionality for changing order

centers = [];
counts = [];
counts_sd = [];
for i = 1:length(obj_order)
    i_obj = obj_order(i);
    
    % Horzcat centers
    hist_type = [x_type '_hist_centers'];
    centers = [centers (trk.(hist_type) + obj(i_obj).center)];
    
    % Compute quartiles or mean +/ sd
    switch type
        case 'median'
            y = quantile(obj(i_obj).(fld),[.25 .50 .75]);
            tmp_sd = [];
            
        case 'mean'
            tmp = obj(i_obj).(fld);
            switch y_type
                case 't'
                    tmp(tmp > 50) = 50;
            end
            switch y_type
                case 'v'
            end
            switch y_type
                case 'a'
            end
            tmp_m = nanmean(tmp);
            tmp_sd = nanstd(tmp);
    end
    
    counts = [counts tmp_m];
    counts_sd = [counts_sd tmp_sd];
end

% Set x data
x = centers';
if strcmp(x_type,'p')
    x = pixToCm(x,run);
    xL = [0 pixToCm(trk.length,run)];
    x_label = x_str{1};
else
    
end

% Set y data
counts = counts';
counts_sd = counts_sd';
y = counts;
y_err = [(counts-counts_sd) (counts+counts_sd)];

switch y_type
    case 't'
        y_label = y_str{1};
    case 'v'
        y_label = y_str{2};
        y = pixToCm(y,run);
        y_err = pixToCm(y_err,run);
    case 'a'
        y_label = y_str{3};
        y = pixToCm(y,run);
        y_err = pixToCm(y_err,run);
    case 'p'
end

yL = [min(min(y))-abs(0.2*min(min(y))) max(max(y))+0.2*max(max(y))];
% yL = [min(min(y_err)) max(max(y_err))];

% Define line properties
gray = [0.6 0.6 0.6];
l_color = {[0 0 0],gray,gray};
l_width = {1,1,1};

% Plot data
for i = 1:size(y,2)
    hline(i) = line('Parent',hax,'XData',x,'YData',y(:,i),...
        'Color',l_color{i},'LineWidth',l_width{i});
end

% Format axes
ylabel(y_label);
xlabel(x_label);
set(hax,'XLim',xL,'YLim',yL);





