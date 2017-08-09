function vTrackFig()
%
%
%
%

% Created: 12/9/12 - SRO


obj_type.values = [1 2 3 4 6 5];

% Make spikes substruct for each stimulus value and condition value
for m = 1:length(obj_type.values)
    n = 1;
    cspikes(m,n) = filtspikes(spikes,0,'stimcond',obj_type.values(m));
end

% --- Make raster plot for each cspikes substruct
for m = 1:size(cspikes,1)       % m is number of stimulus values
    h.r.ax(m) = axes;
    defaultAxes(h.r.ax(m));
    for n = 1:size(cspikes,2)   % n is number of conditions
        h.r.l(m,n) = raster(cspikes(m,n),h.r.ax(m),1,0);
    end
end
h.r.ax = h.r.ax';
set(h.r.ax,'Box','on')


% Set axes properties
hTemp = reshape(h.r.ax,numel(h.r.ax),1);
ymax = setSameYmax(hTemp);
removeAxesLabels(hTemp)
defaultAxes(hTemp)
gray = [0.85 0.85 0.85];
set(hTemp,'YColor',gray,'XColor',gray,'XTick',[],'YTick',[]);

% Set stimulus condition as title
for i = 1:length(obj_type.values)
    temp{i} = round(obj_type.values(i));
end
set(cell2mat(get(h.r.ax,'Title')),{'String'},temp','Position',[1 0 1]);  %'Position',[1.4983 0 1]


% --- Make PSTH for each cspikes substruct
for m = 1:size(cspikes,1)       % m is number of stimulus values
    h.psth.ax(m) = axes;
    for n = 1:size(cspikes,2)   % n is number of conditions
        [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),50);
        %                         [n_avg n_sem centers edges junk] = psth2sem(cspikes(m,n),100);
        
        h.psth.n(m,:,n) = n_avg;
        [h.psth.l(m,n) h.psth.sem(m,n)] = plotPsth2sem(n_avg,n_sem,centers,h.psth.ax(m));
        %             [h.psth.l(m,n) temp h.psth.n(m,:,n) centers] = psth(cspikes(m,n),50,h.psth.ax(m),1);
    end
    h.psth.ax = h.psth.ax';
end


% Set axes properties
setRasterPSTHpos(h)
hTemp = reshape(h.psth.ax,numel(h.psth.ax),1);
ymax = setSameYmax(hTemp,15);
removeInd = 1:length(hTemp);
keepInd = ceil(length(hTemp)/2) + 1;
removeAxesLabels(hTemp(setdiff(removeInd,keepInd)))
defaultAxes(hTemp,0.25,0.15)



% --- Subfunctions --- %

function setRasterPSTHpos(h)

nstim = length(h.r.ax);
ncol = ceil(nstim/2);
rrelsize = 0.65;                      % Relative size PSTH to raster
prelsize = 1-rrelsize;

% Set matrix position
margins = [0.05 0.02 0.05 0.005];
matpos = [margins(1) 1-margins(2) 0.37 1-margins(4)];  % Normalized [left right bottom top]

% Set space between plots
s1 = 0.003;
s2 = 0.035;
s3 = 0.02;

% Compute heights
rowheight = (matpos(4) - matpos(3))/2;
pheight = (rowheight-s1-s2)*prelsize;
rheight = (rowheight-s1-s2)*rrelsize;

% Compute width
width = (matpos(2)-matpos(1)-(ncol-1)*s3)/ncol;

% Row positions
p1bottom = matpos(3) + rowheight;
p2bottom = matpos(3);
r1bottom = p1bottom + pheight + s1;
r2bottom = p2bottom + pheight + s1;

% Compute complete positions
for i = 1:nstim
    if i <= ncol
        col = matpos(1)+(width+s3)*(i-1);
        p{i} = [col p1bottom width pheight];
        r{i} = [col r1bottom width rheight];
    elseif i > ncol
        col = matpos(1)+(width+s3)*(i-1-ncol);
        p{i} = [col p2bottom width pheight];
        r{i} = [col r2bottom width rheight];
    end
end

% Set positions
set([h.psth.ax; h.r.ax],'Units','normalized')
set(h.psth.ax,{'Position'},p')
set(h.r.ax,{'Position'},r')







