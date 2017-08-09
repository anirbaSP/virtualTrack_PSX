function h = plotRunAccelerationInTrial(run,trials,hfig,useCmap)
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


% Make axis for position data
h.ax = axes('Parent',hfig);
defaultAxes(h.ax);

% Compute velocity and acceleration if necessary
if size(run.position_data,3) < 3
    run = computeRunVelocityAcceleration(run);
end

% Set position data
p = run.position_data;
a = p(:,trials,4);
p = p(:,trials,2);

% Convert pixel position to cm
p = pixToCm(p,run);
a = pixToCm(a,run);

% Axis limits
xL = [0 pixToCm(run.trial(1).trk.length,run)];
yL = [min(min(a(:,:))) max(max(a(:,:)))*1.02];

% Use color to indicate trial number
if useCmap
cmap = getCmapValues('jet',run.trial_number);
else
   cmap = zeros(run.trial_number,3); 
end

for i = 1:size(p,2)
    line(p(:,i),a(:,i),'Color',cmap(trials(i),:));
end

% Reverse axis
set(h.ax,'XDir','reverse')

% Format axes
ylabel('Acceleration (cm/s)');
xlabel('Position (cm)');
set(h.ax,'XLim',xL,'YLim',yL);


