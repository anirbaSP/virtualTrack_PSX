function plotRunTrial(run,trials,useCmap)
%
%
%
%

% Created: SRO - 6/19/12


if nargin < 2 || isempty(trials)
    trials = 1:run.trial_number;
end

if nargin < 3 || isempty(useCmap)
    useCmap = 1;
end

if length(trials) == 1
    useCmap = 0;
end

run = updateRun(run);

% Make figure
h.fig = portraitFigSetup;
addSaveFigTool(h.fig);

% Make track
if length(trials) == 1
    trk = run.trial(trials).trk;
else
    trk = run.trial(1).trk;
end
h.trk = makeTrkFig(trk,h.fig);

% Make time vs position plot
plot_type = {
    {'p','t'},...
    {'p','v'},...
    {'p','a'},...
    {'t','p'},...
    {'t','v'},...
    {'t','a'},...
    };

% Temporarily put this here
run = reformatRewardData(run);

for i = 1:length(plot_type)   
    h.ax(i) = plotRunData(run,trials,plot_type{i}{1},plot_type{i}{2},...
        h.fig,[],useCmap);
end

setAxes([h.trk.ax h.ax],8,1,[],[],h.fig);



