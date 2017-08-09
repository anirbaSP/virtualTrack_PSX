function h = runPosHist(run,hfig,hax)
%
%
%
%
%

% Created: SRO - 6/9/12



% Make figure
if nargin < 2 || isempty(hfig)
    h.fig = portraitFigSetup;
else
    h.fig = hfig;
end

% Make axes
if nargin < 3 || isempty(hax)
    h.ax = axes('Parent',h.fig,'Position',[0.1300    0.7714    0.7750    0.1536]);
else
    h.ax = hax;
end

% Get position data
p = run.position_data;

% Remove NaNs from trials not completed
p(:,run.trial_number:end,:) = [];

% Remove NaNs from samples not collected (because actual sample rate was
% lower than expected when matrix was allocated).

% Get positions
p = p(:,:,2);
p = p(1:end);
% p = mod((p+run.display_offset-1),run.trial(1).trk.length) + 1;


% Convert pixels to cm
p = pixToCm(p,run);

% Set bins (use track from first trial)
% bins = linspace(1,run.trial(1).trk.length,100);
bins = 1:2:pixToCm(run.trial(1).trk.length,run);

% Get counts
c = histc(p,bins);

% % Remove last bin
% c(end) = [];
% bins(end) = [];

% Convert counts to fraction
c = c./sum(c);


% Make histogram
h.bar = bar(h.ax,bins,c);
defaultAxes(h.ax);

% Set x and y limits
xL = [0 max(bins)];
set(h.ax,'XLim',xL);
box off











a = 1;
