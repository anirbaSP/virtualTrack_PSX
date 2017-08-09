function hax = plotRunData(run,trials,x_type,y_type,hfig,hax,useCmap)
%
%
%
%
%

% Created: SRO - 6/21/12


if nargin < 2 || isempty(trials)
    trials = 1:run.trial_number;
end

if nargin < 3 || isempty(x_type)
    x_type = 'p';
end

if nargin < 4 || isempty(y_type)
    y_type = 't';
end

if nargin < 5 || isempty(hfig)
    hfig = portraitFigSetup;
end

if nargin < 6 || isempty(hax)
    % Make axis for position data
    hax = axes('Parent',hfig);
    defaultAxes(hax,0.32,0.043);
end

if nargin < 7 || isempty(useCmap)
    useCmap = 0;
end

% Set position data
p = run.position_data(:,trials,:);

% Set x data
[x x_label xL] = setRunData(p,x_type,run);

% Set y data
[y y_label yL] = setRunData(p,y_type,run);

% Use color to indicate trial number
if useCmap
    cmap = getCmapValues('jet',run.trial_number);
else
    cmap = zeros(run.trial_number,3);
    cmap(:,3) = 1;
end

% Plot data
for i = 1:size(y,2)
    line(x(:,i),y(:,i),'Color',cmap(trials(i),:));
end

% Set reward data
rd = filtReward(run.rd,trials);
x_r = computeRewardPositions(run,rd,x_type);

% Plot rewards
line('Parent',hax,'XData',x_r,'YData',ones(size(x_r))*yL(2)*0.97,...
    'LineStyle','none','Marker','o','MarkerSize',4,...
    'MarkerEdgeColor',[1 0 0]);

% Reverse axis
if strcmp(x_type,'p')
    set(hax,'XDir','reverse')
end
if strcmp(y_type,'p')
    set(hax,'YDir','reverse')
end

% Format axes
ylabel(y_label);
xlabel(x_label);
set(hax,'XLim',xL,'YLim',yL);


function [d str lim] = setRunData(p,type,run)

switch type
    case 't'
        d = p(:,:,1);
        str = 'Time (s)';
        lim = [0 run.trial(1).trial_duration];
    case 'p'
        d = p(:,:,2);
        % Add NaN add end of lap to avoid clutter of line crossing entire figure
        for i = 1:size(d,2)
            ind = abs(diff(d(:,i))) > 2000;
            d(ind,i) = NaN;
        end
        str = 'Position (cm)';
    case 'v'
        d = p(:,:,3);
        str = 'Velocity (cm/s)';
    case 'a'
        d = p(:,:,4);
        str = 'Acceleration (cm/s^2)';
end

if any(strcmp(type,{'p','v','a'}))
    d = pixToCm(d,run);
end
if any(strcmp(type,{'v','a'}))
    lim = [min(min(d)) max(max(d(:,:)))*1.01];
elseif strcmp(type,'p')
    lim = [0 pixToCm(run.trial(1).trk.length,run)];
end


function rd = filtReward(rd,trials)

tmp = ismember(rd.trial_number,trials);
flds = fields(rd);
for i = 1:length(flds)
    rd.(flds{i}) = rd.(flds{i})(tmp);
end

function x_r = computeRewardPositions(run,rd,x_type)

switch x_type
    
    case 'p'
        x_r = pixToCm(rd.position,run);
    case 't'
        x_r = rd.time_in_trial;
    otherwise
        
end



