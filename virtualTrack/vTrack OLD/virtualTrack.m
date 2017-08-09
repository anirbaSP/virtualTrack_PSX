function virtualTrack(mouseCode,cueType)
%
%
%
%

% Created: SRO - 3/31/12
% Modified: SRO - 4/2/12

%

if nargin < 1 || isempty(mouseCode)
    mouseCode = 'test';
end

if nargin < 2 || isempty(cueType)
    cueType = 'cue 1';
end

% --- Set paramters

rewardTime = 0.5;
trial_time = 720;

sdef = screenDefs;
gain = sdef.gain;
updateFreq = 40;
updateInterval = 1/updateFreq;
solenoidOpenTime = sdef.solenoidOpenTime;
solenoidShort = sdef.solenoidShort;
n_rewards = 0;
backgroundGray = 100;
darkGray = 25;

total_trials = 100;
d_thresh_initiation = 20;
iti = 7;
sessionActive = 1;
zone_width = [300 500];
flag.parallelport = 0;
reward_limit = 100;
% Cue locations
cue_location = [2150 9690];

% --- Initialize visual stimulation
clear mex
InitializeMatlabOpenGL;

% --- Setup screen
sdef = screenDefs;
screenNum = sdef.screenNum;
workRes = NearestResolution(sdef.screenNum,sdef.width,sdef.height,sdef.frameRate);
SetResolution(screenNum,workRes);
a = sdef.a;
b = sdef.b;

% --- Define analog input
ai = aiSetup();

% --- Define analog output
% ao = aoSetup();

% --- Define digital outputs
daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    dio = digitalio('nidaq','Dev1');
    hwlines = addline(dio,0,'out');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    dio = digitalio('mcc','0');
    hwlines = addline(dio,0,'out');
end

% --- Define parallel port trigger
if flag.parallelport
    p_port = digitalio('parallel','LPT1');
    hwline = addline(p_port,0:1,2,'out','bitLine');    % pins 1,14
    parent = get(p_port.bitLine, 'Parent');
    parentuddobj = daqgetfield(parent{1},'uddobject');
    bitLine = 1:2;
    bitOn = 0;
    bitOff = 1;
    putvalue(parentuddobj,[bitOff bitOff],bitLine);
end

% --- Set up matrix for storing position and times
samples_per_trial = trial_time*updateFreq;
pos = NaN(samples_per_trial,total_trials,2);
pos = single(pos);

% --- Set cue vector
switch cueType
    case 'random'
        cue = round(rand(total_trials,1));
    case 'alternate'
        cue = zeros(total_trials,1);
        cue(2:2:end) = 1;
    case 'cue 1'
        cue = zeros(total_trials,1);
    case 'cue 2'
        cue = ones(total_trials,1);
end


% --- Set up matrix for storing reward times
reward_data = NaN(reward_limit,4);

% --- Set up keys
KbName('UnifyKeyNames')

try
    while (~KbCheck) && (sessionActive)
        num_trials = 0;
        % Assign gray screen
        HideCursor
        Screen('Preference', 'VisualDebuglevel', 3);
        [w,wRect] = Screen(sdef.screenNum,'OpenWindow',darkGray);
        [w2,wRect2] = Screen(3,'OpenWindow',0);
%         Screen('FillRect',w2,darkGray,[960 0 1920 1080]);
%         Screen('FillRect',w2,darkGray,[0 0 960 1080]);
        priorityLevel = MaxPriority(w);
        Priority(priorityLevel);
        
        % Show gray screen
        Screen('Flip',w);
        Screen('Flip',w2);
        
        iti_start = tic;
        t_session_start = tic;
        start(ai);
        
        while (num_trials < total_trials) && (~KbCheck)
            % Make track objects
            obj = makeTrackObjects;
            trk = makeTrack(w,obj);
            tx = trk.tx;
            p_mat = trk.p_mat;
            obj = trk.obj;
            screen_width = trk.screen_width;
            
            % Determine which cue will be presented
            p = cue_location(cue(num_trials+1)+1);
            
            % Set some values
            reward_zone_time = 0;
            %             p = 1;
            distance = sum(zone_width(1));
            lap = 1;
            completedTrack = 0;
            
            % Wait until inter-trial interval has elapsed
            iti_elapsed = toc(iti_start);
            while iti_elapsed < iti && (~KbCheck)
                WaitSecs(0.05);
                iti_elapsed = toc(iti_start);
            end
            
            % Stay in this loop until mouse is running
            d = 0;
            n = get(ai,'SamplesAvailable');
            tmp = getdata(ai,n);
            while d < d_thresh_initiation && (~KbCheck)
                % Compute distance traveled
                d = computeDistance(ai,gain,trk.length);
                WaitSecs(updateInterval);
            end
            
            % Now begin trial
            num_trials = num_trials + 1;
            disp(['trials = ' num2str(num_trials)])
            trial_start_tic = tic;
            trial_elapsed_time = toc(trial_start_tic);
            updateInd = 1;
            
            % Send trigger to DAQ PC
            if flag.parallelport
                putvalue(parentuddobj,[bitOn bitOff],bitLine)
                WaitSecs(0.000001);
                putvalue(parentuddobj,[bitOff bitOff],bitLine)
            end
            
            %--- Display gray screen
%             Screen('FillRect',w2,backgroundGray,[960 0 1920 1080]);
%               Screen('FillRect',w2,backgroundGray,[0 0 960 1080]);
            Screen('FillRect',w,backgroundGray);
%             Screen('Flip',w2);
            Screen('Flip',w);
            % Gray for t seconds before cue
            WaitSecs(0.50);
            
            %--- Display cue
            tile_ind = p_mat(2:end,p);
            c = computeCoordinates(p,p_mat,screen_width,trk.tile_width,trk.width);
            for i = 1:3
                Screen('DrawTexture',w,tx(tile_ind(i)),c{i,1},c{i,2});
            end
            Screen('Flip',w);
            
            putvalue(dio.Line(1),1);
            short_open = solenoidShort;
            WaitSecs(short_open);
            putvalue(dio.Line(1),0);
            WaitSecs(1.5-short_open);
            %             WaitSecs(1.25);
            
            pp = p;
            [p d] = computePosition(ai,p,gain,trk.length);
            p = pp;
            
            t_start = tic;
            while (trial_elapsed_time < trial_time) && (~KbCheck)
                
                [p d] = computePosition(ai,p,gain,trk.length);
                distance = distance + d;
%                 disp(['p = ' num2str(p)]);
                if floor(distance/trk.length)+1 > lap
                    lap = lap + 1;
                    completedTrack = 1;
                end
                
                tile_ind = p_mat(2:end,p);
                c = computeCoordinates(p,p_mat,screen_width,trk.tile_width,trk.width);
                for i = 1:3
                    Screen('DrawTexture',w,tx(tile_ind(i)),c{i,1},c{i,2});
                end
                Screen('Flip',w);
                
                % Store time and position
                pos(updateInd,num_trials,1) = toc(t_start);
                pos(updateInd,num_trials,2) = p;
                updateInd = updateInd + 1;
                
                % Determine whether in reward zone
                p_mid = cue_location(cue(num_trials)+1);
                if p <= p_mid+zone_width(1) && p >= p_mid-zone_width(2) && completedTrack
                    reward_zone_time = reward_zone_time + 1;
                    p_good = 1;
                else
                    reward_zone_time = 0;
                    p_good = 0;
                end
                
                % Deliver reward if in target zone for time = rewardTime
                if reward_zone_time > rewardTime/updateInterval && completedTrack
                    putvalue(dio.Line(1),1);
                    WaitSecs(solenoidOpenTime);
                    putvalue(dio.Line(1),0);
                    reward_zone_time = 0;
                    completedTrack = 0;
                    n_rewards = n_rewards + 1;
                    disp(['rewards = ' num2str(n_rewards)])
                    reward_data(n_rewards,1) = toc(t_session_start);
                    reward_data(n_rewards,2) = toc(trial_start_tic);
                    reward_data(n_rewards,3) = num_trials;
                    reward_data(n_rewards,4) = p;
                    reward_data(n_rewards,5) = cue(num_trials);
                    
%                     Change hold time based on performance
                    switch n_rewards
                          case 10
                            rewardTime = 0.5
                        case 20
                            rewardTime = 0.6
                        case 30
                            rewardTime = 0.6
                        case 20
                            rewardTime = 0.7
                        case 30
                            rewardTime = 0.8
                    end
                    
                end
                
                % Wait for update interval
                tmp_t = toc(t_start);
                if tmp_t < updateInterval
                    WaitSecs(updateInterval-tmp_t);
                end
                
                % Update elapsed trial time
                trial_elapsed_time = toc(trial_start_tic);
                
            end  % Trial ends
            
            % Finish trial. Set screen to dark gray
            
            Screen('FillRect',w,darkGray);
%             Screen('FillRect',w2,darkGray,[960 0 1920 1080]);
              Screen('FillRect',w2,darkGray,[0 0 960 1080]);
            Screen('Flip',w);
            Screen('Flip',w2);
            
            % Begin inter-trial interval
            iti_start = tic;
            
            % Save data from last trial
            savePositionMatrix(pos,trk,cue,reward_data,num_trials,mouseCode);
            
        end  % Session ends
        sessionActive = 0;
        
    end  % Abort
    
catch
    stop(ai)
    Screen('CloseAll')
    delete(ai);
    delete(dio);
    Priority(0);
    ShowCursor
    psychrethrow(psychlasterror);
    clear mex
    % Save position matrix
    savePositionMatrix(pos,trk,cue,reward_data,num_trials,mouseCode);
end
stop(ai)
Screen('CloseAll')
delete(ai);
delete(dio);
Priority(0);
ShowCursor
clear mex
% putvar(trk)

% Save position matrix
savePositionMatrix(pos,trk,cue,reward_data,num_trials,mouseCode);

function ai = aiSetup()

daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    ai = analoginput('nidaq','Dev1');
    set(ai,'SampleRate',10000,'TriggerType','Immediate','InputType','SingleEnded');
    ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
    set(ch(1),'InputRange',[-10 10]);
    set(ch(1),'SensorRange',[0 5]);
    set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    ai = analoginput('mcc',0);
    set(ai,'SampleRate',10000,'TriggerType','Immediate');
    ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
    set(ch(1),'InputRange',[-10 10]);
    set(ch(1),'SensorRange',[0 5]);
    set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire
else
    error('No daq device installed')
end


function  c = computeCoordinates(p,p_mat,sw,tile_w,trk_w)
% p:
% p_mat:
% sw: screen_width
% tile_w: tile_width
% trk_w: track width

% Coordinates of tile 1
t1_left = mod(p-1,tile_w);
t1_right = tile_w;
t1_w = t1_right - t1_left;
c{1,1} = [t1_left 0 t1_right trk_w];
c{1,2} = [0 0 t1_w trk_w];

% Coordinates of tile 2
t2_left = 0;
t2_right = sw-t1_w;
t2_right(t2_right>tile_w) = tile_w;
t2_w = t2_right - t2_left;
c{2,1} = [t2_left 0 t2_right trk_w];
c{2,2} = [t1_w 0 t1_w+t2_w trk_w];

% Coordinates of tile 3
t3_left = 0;
t3_right = sw-t1_w-t2_w;
t3_right(t3_right>tile_w) = tile_w;
t3_w = t3_right - t3_left;
c{3,1} = [t3_left 0 t3_right trk_w];
c{3,2} = [t1_w+t2_w 0 t1_w+t2_w+t3_w trk_w];

% for m = 1:3
%     for n = 1:2
%         disp([m n])
%         disp(c{m,n})
%     end
% end


function d = computeDistance(ai,gain,trackLength)
% Set threshold for detecting complete revolution of disk
thresh = 1;

% Set ai input range
r = 5;

% Get data from daq engine
n = 0;
% tic
while n == 0
    n = get(ai,'SamplesAvailable');
end
% toc
d = getdata(ai,n);
d = d(:,1);  %  Chn0/Ind1 is absolute position encoder

% Compute distance traveled
d = diff(d);
d(abs(d) > thresh) = NaN;
d = nansum(d);
d = d/r;
d = gain*d*trackLength;

function [p d] = computePosition(ai,p,gain,trackLength)

% Set threshold for detecting complete revolution of disk
thresh = 1;

% Set ai input range
r = 5;

% Get data from daq engine
n = 0;
while n == 0
    n = get(ai,'SamplesAvailable');
end
d = getdata(ai,n);
d = d(:,1);  %  Chn0/Ind1 is absolute position encoder

% Compute distance traveled
d = diff(d);
d(abs(d) > thresh) = NaN;
d = nansum(d);
d = d/r;
d = gain*d*trackLength;

if abs(d) > 6.4
    % Compute new position
    p = fix(p - d);
    p = mod(p,trackLength);
else
    p = p;
end

p(p==0) = 1;

function savePositionMatrix(pos,trk,cue,reward_data,num_trials,mouseCode)

% % Remove NaNs
% if size(pos) < num_trials + 1
%     pos(:,num_trials+1:end,:) = [];
% end

run.cue = cue;
run.pos = pos;
run.trk = trk;
run.reward = reward_data;
dir = 'C:\SRO DATA\vStim Data\runTrackData\';
fname = [date '_' mouseCode];
save([dir fname],'run')




