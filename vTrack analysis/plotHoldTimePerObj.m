function h = plotHoldTimePerObj(run,trials,hFig)
%
%
%
%

% Created: SRO - 6/28/12


if nargin < 2 || isempty(trials)
    trials = 1:size(run.position_data,2);
end

if nargin < 3
    % Figure setup
    %hFig = portraitFigSetup;
    hFig = figure;
end

filter_trials = 1;

if length(run) > 1
    filter_trials = 0;
    % Concatenate relevant run data
    flds = {'trial','reward','time_in_zone','led'};
    r = run(1);
    
    for i = 2:length(run)
        tmp = run(i);
        for m = 1:length(r.obj_trk.obj)
            for n = 1:length(flds)
                r.obj_trk.obj(m).(flds{n}) = horzcat(r.obj_trk.obj(m).(flds{n}),tmp.obj_trk.obj(m).(flds{n}));
            end
        end
    end
    
    run = r;
end

led_val = [0 1];
% run.use_led = 0;

obj = run.obj_trk.obj;
% obj = obj([1 4 3 2]);

for i = 1:length(obj)

    if filter_trials
        % Filter on trials
        t_ind = ismember(obj(i).trial,trials);
        obj(i).time_in_zone = obj(i).time_in_zone(t_ind);
        if isfield(obj,'led') && length(obj(i).trial) == length(obj(i).led)
            obj(i).led = obj(i).led(t_ind',:);
        end
        if size(obj(i).led,2) > 1
            obj(i).led(obj(i).led(:,2) == 1) = 2;
            led_val = [0 1 2];
            obj(i).led(:,2) = [];
        end
    end
    
    for n = 1:length(led_val)
        
        if isfield(run,'use_led') && run.use_led
            % Filter on LED value
            ind = ismember(obj(i).led,led_val(n));
            tmp_time_in_zone = obj(i).time_in_zone(ind);
        else
            tmp_time_in_zone = obj(i).time_in_zone;
        end
        
        % Find hold times exceeding threshold for reward
        if datenum(run.date) < datenum('26-Jun-2012 10:00:00')
            tmp = tmp_time_in_zone > run.trial(1).time_hold_for_reward*1.55;
        else
            tmp = tmp_time_in_zone > run.trial(1).time_hold_for_reward;
        end
        f(i,n) = sum(tmp)/length(tmp_time_in_zone);
        
        % Compute CI using Clopper-Pearson interval (code from WB)
        p_upper_bnd = @(x, N, beta)((1 + (N - x)/((x+1)*finv(1-beta, 2*(x+1), 2*(N-x))))^-1);
        p_lower_bnd = @(x, N, beta)((1 + (N-x+1)/((x*finv(beta, 2*x, 2*(N-x+1)))))^-1);
        N = length(tmp);
        x = sum(tmp);
        beta = 0.05/2;
        
        tmp_upper =  p_upper_bnd(x,N,beta);
        tmp_upper(isnan(tmp_upper)) = 1;
        f_CI(i,1,n) = tmp_upper;
        tmp_lower =  p_lower_bnd(x,N,beta);
        tmp_lower(isnan(tmp_lower)) = 0;
        f_CI(i,2,n) = tmp_lower;
        
    end
end

f_CI(isnan(f_CI)) = 1;

% Objects
x = (1:size(f,1))';
x_label = 'Track objects';
x_label = '';
xL = [min(x)-0.5 max(x)+0.5];

% Set y values
y = f;
y_err = f_CI; % Clopper-Pearson
y_label = 'f';
yL = [0 1];


% Define line properties
gray = [0.4 0.4 0.4];
l_color = {[0 0 0],[1 0 0],[0 0 1]};
l_width = {1.5,1.5,1.5};

a = 1;


% Plot data probability of stopping in target zone
h.ax = axes('Parent',hFig);
defaultAxes(h.ax,0.12,0.1,10);
for i = 1:size(y,2)
        hline(i) = line('Parent',h.ax,'XData',x,'YData',y(:,i),...
            'Color',l_color{i},'LineWidth',l_width{i});
end

% Add error bars
l_color = {[0.4 0.4 0.4],[200/256 0 0],[0 0 200/256]};
for i = 1:size(y_err,3)
     %herr(i) = addErrBar2(x,y(:,i),y_err(:,1,i),y_err(:,2,i),'y',h.ax);
        set(herr(i),'Color',l_color{i});
end

% Format axes
ylabel(y_label);
xlabel(x_label);
set(h.ax,'XLim',xL,'YLim',yL);


% Add track to plot
h.trk = makeTrkFig(run.obj_trk,hFig);

% Format axes
params.matpos = [0.2 0.1 1 1];
params.cellmargin = [0.01 0.01 0.05 0.05];
setAxes([h.trk.ax h.ax],4,2,[7 1],params,hFig);

 
set(h.trk.ax,'Position',[0.2700   0.8    0.4450    0.1937],'XDir','normal');
axis(h.trk.ax,'off');

a = 1;

