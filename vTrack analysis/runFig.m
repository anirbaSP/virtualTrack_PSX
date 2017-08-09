function runFig(run)
%
%
%
%
%

% Created: SRO - 6/9/12




% Make figure
h.fig = portraitFigSetup();

% Show track
h.ax.track = axes;
makeTrkFig(run.trial(1).trk,h.fig,h.ax.track);
set(h.ax.track,'Position',[0.1313    0.5097    0.7750    0.8150]);


% Make position histogram
h.hist = runPosHist(run,h.fig);
set(h.hist.ax,'Position',[0.1313    0.68    0.7750    0.1549]);
set(h.hist.ax,'XLim',get(h.ax.track,'XLim'));


% 