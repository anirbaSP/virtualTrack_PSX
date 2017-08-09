function ar=tools()

    ar.plotHoldTimePerObj         = @plotHoldTimePerObj;
    ar.plot_LEDtime               = @plot_LEDtime;
    ar.plotPositionAlignedToEntry = @plotPositionAlignedToEntry;
    ar.excl_tLed                  = @excl_tLed;
    ar.mkGrating                  = @mkGrating;
    ar.join_files                 = @join_files;
    ar.holdTimeHist               = @holdTimeHist;
    ar.excl_tLed_cntrl            = @excl_tLed_cntrl;
    ar.excl_tLed_hist             = @excl_tLed_hist;
end

function hFig = plotHoldTimePerObj(run,trials,hFig)
% Created: SRO - 6/28/12
% Modified: AR - 9/26/13


if nargin < 2 || isempty(trials)
    trials = 1:size(run(1).position_data,2);
end

if nargin < 3
    hFig = figure;
end

filter_trials = 1;

if length(run) > 1
    %filter_trials = 0;
    % Concatenate relevant run data
    flds = {'trial','reward','time_in_zone','led'};
    r = run(1);
    
    for i = 2:length(run)
        tmp = run(i);
        for m = 1:length(r.obj_trk.obj)
            for n = 1:length(flds)
                %if n<4
                    r.obj_trk.obj(m).(flds{n}) = horzcat(r.obj_trk.obj(m).(flds{n}),tmp.obj_trk.obj(m).(flds{n}));
                %elseif n==4
                   % r.obj_trk.obj(m).(flds{n}) = horzcat(r.obj_trk.obj(m).(flds{n})',tmp.obj_trk.obj(m).(flds{n})')';
                %end
            end
        end
    end
    
    run = r;
end

led_val = [0 1];

obj = run.obj_trk.obj;

for i = 1:length(obj)

    if filter_trials
        % Filter on trials
        t_ind = ismember(obj(i).trial,trials);
        obj(i).time_in_zone = obj(i).time_in_zone(t_ind);
        
        if size(obj(i).led,1)<size(obj(i).led,2)
            obj(i).led=obj(i).led';
        end
  
        if isfield(obj,'led') && length(obj(i).trial) == length(obj(i).led)
            obj(i).led = obj(i).led(t_ind',:); 
        end
 
        obj(i).led(obj(i).led(:,1) == 1) = 2;
        led_val = [0 1 2];
    
    if size(obj(i).led,2) > 1
        obj(i).led(obj(i).led(:,2) == 1) = 2;
        led_val = [0 1 2];
        obj(i).led(:,2) = [];
    end
 end
    
    for n = 1:length(led_val)
        
        if isfield(run,'use_led') && run.use_led
            % Filter on LED value
            ind = ismember(obj(i).led',led_val(n));
            tmp_time_in_zone = obj(i).time_in_zone(ind);
        else
            tmp_time_in_zone = obj(i).time_in_zone;
        end
  
        
        % Find hold times exceeding threshold for reward
        tmp = tmp_time_in_zone > run.trial(1).time_hold_for_reward;
        f(i,n) = sum(tmp)/length(tmp_time_in_zone);
        N = length(tmp);
        x = sum(tmp);
        if N>1
            a_CI(i,1,n)=binoinv(0.95,N,x/N)/N;
            a_CI(i,2,n)=binoinv(0.05,N,x/N)/N;
            
        end
    end
end

% Objects
x = (1:size(f,1))';
x_label = 'Track objects';
xL = [min(x)-0.5 max(x)+0.5];

% Set y values
y = f;
y_err = a_CI; % Binomial
y_label = 'Stop probability';
yL = [0 1];


% Define line properties
gray = [0.4 0.4 0.4];
l_color = {[0 0 0],[0 0 0],[1 0 0]};
l_width = {1.5,1.5,1.5};

% Plot data probability of stopping in target zone
h.ax = axes('Parent',hFig);
defaultAxes(h.ax,0.12,0.1,10);
for i = 1:size(y,2)
        hline(i) = line('Parent',h.ax,'XData',x,'YData',y(:,i),...
            'Color',l_color{i},'LineWidth',l_width{i});
end


for i = 1:size(y_err,1) 
    hline(i) = line('Parent',h.ax,'XData',[x(i) x(i)],'YData',y_err(i,:,1),...
            'Color',l_color{1},'LineWidth',l_width{1});
end
% Format axes
ylabel(y_label);
xlabel(x_label);
set(h.ax,'XLim',xL,'YLim',yL,'XTick',0:1:4);

% LED trials

if isfield(obj,'led') && length(obj(i).trial) == length(obj(i).led)
    for i = 1:size(y_err,1)
        hline(i) = line('Parent',h.ax,'XData',[x(i) x(i)],'YData',y_err(i,:,3),...
            'Color',l_color{3},'LineWidth',l_width{1});
    end
end

% Format axes
params.matpos = [0.2 0.1 1 1];
params.cellmargin = [0.01 0.01 0.05 0.05];

end

function plot_LEDtime(run,h)
figure(h);
tp=NaN(26,run.trial_number);
for k=1:run.trial_number
    tp(:,k)=run.trial(k).tled'-run.trial(k).tdiode';
end
i=find(~isnan(tp));
plot(sort(tp(i)),(1:length(i))/length(i),'-k');
plot([0.3 0.3], [0 1.0], '--k')
plot([0.17 0.17], [0 1.0], '--k')
plot([0 0.7], [0.5 0.5], '--k')
xlim([0 0.7])
end

function h = plotPositionAlignedToEntry(r)

% AR on November 22,2013
% Modified from plotSpeedAlignedToEntry.m

time_range = 4;
samples = round(time_range*20); % Kluge (effective update rate is ~20 Hz; vTrack needs work)

cv={[0.8 0.8 0.8],[0 0.8 0]};

obj = r.obj_trk.obj;
t = r.position_data(:,:,1);
p = r.position_data(:,:,2);

led_val=[0 1];

for m = 1:length(led_val)
    for i = 1:length(obj)
        
        hFig = figure;
        h.p.ax(1) = gca;
        set(h.p.ax(1),'YLim',[0 4],'XLim',[-1 2000]);
        
        for n = 1:length(obj(i).encounter_time)
            % This object
            trial = obj(i).trial(n);
            entry_p=obj(i).obj_centers(n)+600;
            entry_ind=find(p(:,trial)==entry_p,1);
            if isempty(entry_ind)
                entry_ind=obj(i).entry_ind(n);
            end
            
            % Set data
            if entry_ind + samples > length(p(:,trial))
                skip = 1;
            else
                skip = 0;
            end
            
            if ~skip
                tmp_ind = entry_ind:1:(entry_ind) + samples;
                
                % Get zeroed time values - %AR added this line
                t_tmp=cumsum([0; diff(t(tmp_ind,trial))]);
                p_tmp=cumsum([500; -diff(p(tmp_ind,trial))]);
                
                if size(obj(i).led,1)<size(obj(i).led,2)
                    obj(i).led=obj(i).led';
                end
                
                % Plot position
                if (isfield(r,'use_led') && r.use_led && (obj(i).led(n,1)==led_val(m)))
                    h.p.l(i,n) = line('Parent',h.p.ax(1),'XData',p_tmp,...
                        'YData',t_tmp,'LineWidth',0.5,'Color',cv{i});
                end
            end
            
        end
        
        %with respect to leading edge of the image
        h.p.target_zone(i) = line('Parent',h.p.ax(1),'XData', [860 860],...
            'YData', [0 4],'LineWidth',0.5,'Color','k','Linestyle','--');
        
        h.p.target_zone(i) = line('Parent',h.p.ax(1),'XData', [1360 1360],...
            'YData', [0 4],'LineWidth',0.5,'Color','k','Linestyle','--');
        
        set(hFig,'Position',[1 1 200 200]);
    end
end
end

function holdTimeHist(run)
    
 bin=0:0.1:4;
 color={'k','g','m'};
 sc=[1, -1];
 
 led_val=[0 1];
 obj = run.obj_trk.obj;
 for n = 1:length(led_val)
     hFig = figure;
     hold on
     for i = 1:length(obj)
         ind = ismember(obj(i).led,led_val(n));
         y=histc(obj(i).time_in_zone(ind),bin);
         bar(bin,y*sc(i),'FaceColor',color{i})
     end
     set(hFig,'Position',[1 1 200 200]);
     plot([run.trial(1).time_hold_for_reward run.trial(1).time_hold_for_reward]...
         ,[-60 60],'--k');
     xlim([min(bin) max(bin)])
     ylim([-45 45])
 end
end

function excl_tLed(run0,run,tc,h)

obj(1).tled=[];
obj(2).tled=[];
obj(1).trial=[];
obj(2).trial=[];

for s=1:length(run0)
for k=1:run0(s).trial_number
    %index of objects encountered
    i=run0(s).trial(k).trk.obj_encountered;
    %type of objects encountered
    t=run0(s).trial(k).trk.obj_list;
    
    for m=1:length(unique(t))
        obj(m).tled=[obj(m).tled run0(s).trial(k).tled(i & (t==m))-...
            run0(s).trial(k).tdiode(i & (t==m))];
        obj(m).trial=[obj(m).trial k*ones(1,sum(i & (t==m)))];
    end
end
end
for m=1:length(obj)
disrep=sum(run.obj_trk.obj(m).trial~=obj(m).trial);
if disrep~=0
   display('Error in trial indices..') 
end
end
 for m=1:length(obj)
    obj(m).choice=run.obj_trk.obj(m).choice;
 end
 
 subplot(h);
 hold on
 for m=1:length(obj)
     i=~isnan(obj(m).tled) & (obj(m).tled<tc(2)) & (obj(m).tled>tc(1));
     f(m)=sum(obj(m).choice(i)==1)/length(obj(m).choice(i));
     N = length(obj(m).choice(i));
     x = sum(obj(m).choice(i)==1);
     
     a_CI(m,1)=binoinv(0.95,N,x/N)/N;
     a_CI(m,2)=binoinv(0.05,N,x/N)/N;
     
     plot([m m],a_CI(m,:),'-r','Linewidth',2)
     mean(obj(m).tled(i))
     pause
 end
 plot(1:m,f(:),'-r','Linewidth',2)
end

function excl_tLed_cntrl(run,h)
subplot(h);
hold on

obj = run.obj_trk.obj;
for m=1:length(obj)
    ind = ismember(obj(m).led,0);
    f(m)=sum(obj(m).choice(ind)==1)/length(obj(m).choice(ind));
    N = length(obj(m).choice(ind));
    x = sum(obj(m).choice(ind)==1);

    a_CI(m,1)=binoinv(0.95,N,x/N)/N;
    a_CI(m,2)=binoinv(0.05,N,x/N)/N;
    
    plot([m m],a_CI(m,:),'-k','Linewidth',2)
end
plot(1:m,f(:),'-k','Linewidth',2)
end

function excl_tLed_hist(run,h)

tp=NaN(26,run.trial_number);

for k=1:run.trial_number
    tp(:,k)=run.trial(k).tled'-run.trial(k).tdiode';
end

i=~isnan(tp);

subplot(h)
hist(tp(i),-0.2:0.005:0.5)
xlim([-0.2 0.5])
xlabel('LED onset-Stimulus onset (s)')
ylabel('Trials')

end

function tmp=mkGrating(size,background_pix_val,angle)

%AR on 1/14/2014

sDef=screenDefs;
contrast=0.14;
sf= 0.008;  %4 cycles/500 pixels

gray=background_pix_val;
lum_b=sDef.a*(gray^sDef.b);
lum_max=sDef.a*(255^sDef.b);
white_lum=lum_b+(lum_max*contrast);
inc = (white_lum-lum_b);

nsteps=8;
step=round(1/(nsteps*sf));

phase_v=0:step:(step*(nsteps-1));
phase=phase_v(randi(length(phase_v)));

[x,z]=meshgrid(-size/2:1:size/2); %size = obj.size +1;
lum_y=lum_b+(sin(2*pi*sf*(x-phase))*inc.*Circle(size/2+0.5).*exp(-((x/150).^2)-((z/150).^2)));
y=exp(log(lum_y/sDef.a)/sDef.b);

tmp=imrotate(y,angle);
tmp(tmp==0)=gray;
end

function run=join_files(run)

if length(run) > 1
    % Concatenate relevant run data
    flds = {'trial','reward','time_in_zone','choice','led'};
    flds_tr = {'obj_encountered','obj_list','tled','tdiode'};

    r = run(1);
    
    for i = 2:length(run)
        tmp = run(i);
        %concatenate obj_trk data
        for m = 1:length(r.obj_trk.obj)
            for n = 1:length(flds)
                     r.obj_trk.obj(m).(flds{n}) = horzcat(r.obj_trk.obj(m).(flds{n}),tmp.obj_trk.obj(m).(flds{n}));
            end
        end
        
    end
 
   
    end
        
    run = r;
end



