function h = plotRunPositionInTrial(run,trials,hfig,useCmap,hax)
%
%
%
%
%

% Created: SRO - 6/19/12

if nargin < 2 || isempty(trials)
    trials = 1:run.trial_number;
end

if nargin < 3 || isempty(hfig)
    hfig = portraitFigSetup;
end

if nargin < 4 || isempty(useCmap)
    useCmap = 1;
end

if nargin < 5 || isempty(hax)
    % Make axis for position data
    h.ax = axes('Parent',hfig);
    defaultAxes(h.ax);
else
    h.ax = hax;
end

% Set position data
p = run.position_data;

% Add NaN when when is completed to avoid clutter of line crossing entire
% figure
tmp = p(:,:,2);
for i = 1:size(tmp,2)
    ind = abs(diff(tmp(:,i))) > 2000;
tmp(ind,i) = NaN;
end

% Convert pixel position to cm
tmp = pixToCm(tmp,run);
p(:,:,2) = tmp;

% Get 
p = p(:,trials,:);
xL = [0 pixToCm(run.trial(1).trk.length,run)];
yL = [0 max(max(p(:,:,1)))*1.02];

% Use color to indicate trial number
if useCmap
cmap = getCmapValues('jet',run.trial_number);
else
   cmap = zeros(run.trial_number,3); 
end
    

for i = 1:size(p,2)
    line(p(:,i,2),p(:,i,1),'Color',cmap(trials(i),:));
end

% Reverse axis
set(h.ax,'XDir','reverse')

% Format axes
ylabel('Time (s)');
xlabel('Position (cm)');
set(h.ax,'XLim',xL,'YLim',yL);


