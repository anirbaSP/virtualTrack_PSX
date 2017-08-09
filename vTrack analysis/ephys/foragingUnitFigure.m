function foragingUnitFigure(s,r,b)
%
% INPUT
%   s: spikes struct
%   r: run struct
%   b: Flag structure with field b.save, b.print, b.pause, b.close
%

% Created: SRO - 2/14/13



if nargin < 3
    b.pause = 0;
    b.save = 0;
    b.print = 0;
    b.close = 0;
end



rdef = RigDefs;


% Figure setup
h.fig = landscapeFigSetup;
set(h.fig,'Visible','off','Position',[792 399 1056 724])
addSaveFigTool(h.fig);

%Set variables
obj = r.obj_trk.obj;

% Make position raster for each object
for i = 1:length(obj)
    
    tmp = filtspikes(s,0,'obj_type',i);
    h_tmp(i) = pRaster(tmp,h.fig);
    
end

% Format position rasters
params.matpos = [0.05 0.76 0.55 0.18];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.01 0 0];    % [L R T B]
setaxesOnaxesmatrix(tmp.x,1,length(tmp.ax),1:length(tmp.ax),params);


% Make position histogram
for i = 1:length(obj)
    
    tmp = filtspikes(s,0,'obj_type',i);
    h_tmp(i) = pPsth(tmp,h.fig);
    
end

% Format position psths
params.matpos = [0.05 0.76 0.55 0.18];  % [L B W H]
params.figmargin = [0 0 0 0];
params.matmargin = [0 0 0 0];
params.cellmargin = [0 0.01 0 0];    % [L R T B]
setaxesOnaxesmatrix(h_tmp.ax,1,length(h_tmp.ax),1:length(h_tmp.ax),params);


% Compute spatial receptive field (fit w/ gaussian)


% Raster (t = 0, object at center of RF)


% PSTH (aligned to object at center of RF)




% PSTH aligned to reward delivery




