function runSummary(run,n_bins,n_bins_t,filt_property,filt_value)
%
%
%
%

% Created: SRO - 6/22/12



if nargin < 2 || isempty(n_bins)
    n_bins = 20;
end

if nargin < 3 || isempty(n_bins_t)
    n_bins_t = 40;
end

if nargin < 4 || isempty(filt_property)
    filt_property = [];
end

if nargin < 5 || isempty(filt_value)
    filt_value = [];
end



% Make figure
h.fig = portraitFigSetup;
addSaveFigTool(h.fig);

% Make object track
run = updateRun(run);
if ~isfield(run,'obj_trk')
    run = make_obj_trk(run);
end

if ~isfield(run.trial(1).trk,'obj_encountered')
    run = objEncountered(run);
end

% Compute data
run = computeObjTrkHist(run,n_bins);

% Make trk figure
trk = run.obj_trk;
h.trk = makeTrkFig(trk,h.fig);
set(h.trk.ax,'XDir','normal');

% Plot data
plot_type = {
    {'p','t'},...
    {'p','v'},...
    {'p','a'},...
    };

for i = 1:length(plot_type)
h.ax(i) = plotObjTrkHist(run,plot_type{i}{1},plot_type{i}{2},...
    h.fig,[],n_bins,n_bins_t,0);
end

% Format axes
setAxes([h.trk.ax h.ax],8,1,[],[],h.fig);



