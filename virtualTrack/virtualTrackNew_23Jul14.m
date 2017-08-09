function mouse = virtualTrackNew(table_track,mouse,save_run)
%
%
%
%

% Created: SRO - 3/31/12
% Modified: SRO - 5/23/12 - 6/8/12


if nargin < 1 || isempty(table_track)
    % Choose track struct
end

if nargin < 2 || isempty(mouse)
    % Choose mouse
    mouse.mouse_code = 'test';
end

if nargin < 3 || isempty(save_run)
    save_run = 1;
end


% --- Make 'run' and 'track' structs
run = makeRunStruct(table_track,mouse);
run.save_run = save_run;
run.session_start_time = datestr(now);

% --- Setup screen
sdef = screenDefs;
screenNum = sdef.screenNum;
workRes = NearestResolution(sdef.screenNum,sdef.width,sdef.height,sdef.frameRate);
Screen('Preference', 'VisualDebuglevel', 1);
Screen('Preference', 'SkipSyncTests', 2 );
Screen('Preference', 'Verbosity', 0);
SetResolution(screenNum,workRes);
a = sdef.a;
b = sdef.b;
white_luminance = 50;
black_luminance = 0;

% --- Initialize visual stimulation
clear mex
InitializeMatlabOpenGL;

% --- Setup analog input
ai = aiSetup();

% --- Setup analog output (LED, auditory stimulus, etc)
% ao = aoSetup();

% --- Setup digital output to lickport
run.lick_port = lickPortSetup();

% --- Setup digital output to LED
if run.use_led
    run.led = ledSetup(run);
end

% --- Define parallel port trigger
run = parallelPortSetup(run);

% --- If aquiring data
run = udpSetup(run);

% --- Set up keys
KbName('UnifyKeyNames')

% --- Session active flag
session_active = 1;

putvar(run);

try
    HideCursor
    while session_active
        
        % Turn on dark background
        run = displayBlankTrack(run);  % default environment
        
        % Set tic times
        tic_iti_start = tic;
        run.tic_session_start = tic;
        
        % Start data acquisition from rotation encoder
        start(ai);
        
        session_active = keyCheck(session_active);
        
        % --- PRE-TRIAL BEGINS --- %
        while session_active && (run.trial_number-1 < run.number_of_trials)
            
            % Terminate session is reward limit has been reached
            if run.n_rewards >= run.reward_limit
                session_active = 0;
            end
            
            % --- Make Track
            run = makeTrkTextures(run);
            
            % Set solenoid open time
            run = computeSolenoidOpenTime(run);
            
            % --- Set trial specific parameters
            trial_duration = run.trial(run.trial_number).trial_duration;
            iti = run.trial(run.trial_number).iti;
            
            % --- Wait until inter-trial interval has elapsed
            while session_active && toc(tic_iti_start) < iti
                session_active = keyCheck(session_active);
                WaitSecs(0.05);
            end
            
            % --- Stay in this loop until mouse is running
            %             velocity = 0;
            %             while session_active && velocity < trk.threshold_initiation_speed
            %                 velocity = computeVelocity(ai,trk,run);
            %                 session_active = keyCheck(session_active);
            %             end
            
            % Trial "start time"
            run.trial(run.trial_number).start_time = toc(run.tic_session_start);
            
            % Send trigger to DAQ PC
            if run.parallel_port_trigger
                run.trial(run.trial_number).trigger_time = triggerDaq(run);
                % Send run file, trial number, and trial time via udp
                fwrite(run.u,[run.name '*' ...
                    num2str(run.trial_number) '*' ...
                    num2str(run.trial(run.trial_number).start_time)]);
            end
            
            %--- Display gray screen
            %             Screen('FillRect',run.w(2),run.trial(run.trial_number).background_pix_val,[0 0 960 1080]);
%             Screen('FillRect',run.w(2),0,[0 0 0 0]);
            Screen('FillRect',run.w(1),run.trial(run.trial_number).background_pix_val);
%             Screen('Flip',run.w(2));
            Screen('Flip',run.w(1));
            
            % Gray for t seconds before cue
            WaitSecs(run.wait_time_after_trigger);
            
            %reset stimulus freeze state
            run.freeze_state=0;
            
            %--- Display Cue --- %
            %  displayCue;
            
            % Clear data from ai device
            clearDaq(ai,run);
            
            % Keyboard check
            session_active = keyCheck(session_active);
            
            % --- TRIAL BEGINS --- %
            run.tic_trial_start = tic;
            run.tic_hold_time = tic;
            
            disp(['trials = ' num2str(run.trial_number)])
            run.update_index = 1;
            
            displayTrack(run);
            
            while session_active && toc(run.tic_trial_start) < trial_duration
                
                run.tic_update = tic;
                
                % Compute new position and distance travelled
                run = computePosition(ai,run);
                %                 disp(['p = ' num2str(run.p)]);
                %                 toc(run.tic_update)
                
                % Display track
                displayTrack(run);
                %                 toc(run.tic_update)
                
                % Store time and position
                run.position_data(run.update_index,run.trial_number,1) = toc(run.tic_trial_start);
                run.position_data(run.update_index,run.trial_number,2) = run.p;
                
                % Send pulse for syncing daq
                if run.parallel_port_trigger
                    run = syncDaqPulse(run);
                end
                
                % Update track refresh index
                run.update_index = run.update_index + 1;
                
                % Compute and execute reward and output contingencies
                run = computeContingencies(run,ai);
                run.tic_hold_time = tic;
                %                  toc(run.tic_update)
                
                % Wait for update interval
                waitForUpdateInterval(run);
                
                % Keyboard check
                session_active = keyCheck(session_active);
                
            end  % Trial ends
            
            % --- FINISH TRIAL --- %
            run = displayBlankTrack(run);
            if run.use_led
                run.led_state = [0 0];
                putvalue(run.led(2:3).parentuddobj,0,2);
            end
            
            % Set starting position for next trial
            run.p = 1;
            
            % Begin inter-trial interval
            tic_iti_start = tic;
            
            % Save data from last trial
            saveRunData(run,mouse);
            
            % Update trial number
            run.trial_number = run.trial_number + 1;
            
            % Keyboard check
            session_active = keyCheck(session_active);
            
        end  % Session ends
        
        session_active = 0;
        
    end  % Abort
    
catch
    % --- End of session --- %
    mouse = endTrack(ai,run,mouse,psychlasterror);
end
% --- End of session --- %
mouse = endTrack(ai,run,mouse,[]);


% --- SUBFUNCTIONS --- %
function ai = aiSetup()
daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    ai = analoginput('nidaq','Dev1');
    set(ai,'SampleRate',10000,'TriggerType','Immediate','InputType','SingleEnded');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    ai = analoginput('mcc',0);
    set(ai,'SampleRate',20000,'TriggerType','Immediate');
else
    error('No daq device installed')
end
ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
set(ch(1),'InputRange',[-10 10]);
set(ch(1),'SensorRange',[0 5]);
set(ch(1),'UnitsRange',[0 1]);
set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire

function lick_port = lickPortSetup()
daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    dio = digitalio('nidaq','Dev1');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    dio = digitalio('mcc','0');
end
hwlines = addline(dio,0,'out','lickLine');
parent = get(dio.lickLine, 'Parent');
parentuddobj = daqgetfield(parent,'uddobject');
lick_port.parentuddobj = parentuddobj;
lick_port.dio = dio;

function led = ledSetup(run)
hwlines = addline(run.lick_port.dio,1,'out','ledLine');
parent = get(run.lick_port.dio.ledLine, 'Parent');
parentuddobj = daqgetfield(parent,'uddobject');
led.parentuddobj = parentuddobj;
led.dio = run.lick_port.dio;

hwlines(2) = addline(run.lick_port.dio,2,'out','ledLine');
led(2).parentuddobj = parentuddobj;
led(2).dio = run.lick_port.dio;


function run = parallelPortSetup(run)
if run.parallel_port_trigger
    p_port = digitalio('parallel','LPT1');
    hwline = addline(p_port,0:1,2,'out','triggerLine');    % pins 1,14
    parent = get(p_port.triggerLine, 'Parent');
    parentuddobj = daqgetfield(parent{1},'uddobject');
    triggerLine = 1:2;
    bitOn = 0;
    bitOff = 1;
    putvalue(parentuddobj,[bitOff bitOff],triggerLine);
    
    run.p_port.dio = p_port;
    run.p_port.parentuddobj = parentuddobj;
    run.p_port.triggerLine = triggerLine;
    run.p_port.bitOn = 0;
    run.p_port.bitOff = 1;
end

function run = displayBlankTrack(run)
if ~isfield(run,'w')
    Screen('Preference', 'VisualDebuglevel', 1);
    Screen('Preference', 'SkipSyncTests', 2 );
    Screen('Preference', 'Verbosity', 0);
    [run.w(1),wRect] = Screen(run.sdef.screenNum,'OpenWindow',run.trial(run.trial_number).background_pix_val);
    Screen('Preference', 'VisualDebuglevel', 1);
    Screen('Preference', 'SkipSyncTests', 2 );
    Screen('Preference', 'Verbosity', 0);
%     [run.w(2),wRect2] = Screen(3,'OpenWindow',0);
    priorityLevel = MaxPriority(run.w(1));
    Priority(priorityLevel);
%     Screen('FillRect',run.w(2),0,[0 0 0 0]);
end

Screen('FillRect',run.w(1),run.trial(run.trial_number).background_pix_val);
% Screen('FillRect',run.w(2),0,[0 0 0 0]);
Screen('Flip',run.w(1));
% Screen('Flip',run.w(2));

function displayTrack(run)
p_mat = run.p_mat;
p = mod(run.p-run.display_offset,run.trial(run.trial_number).trk.length);
p(p==0) = 1;
tile_ind = p_mat(2:4,p);
tmp = run.trial(run.trial_number).trk;
c = computeCoordinates(p,p_mat,run.sdef.width,tmp.tile_width,tmp.height);
for i = 1:3
    Screen('DrawTexture',run.w(1),run.tx(tile_ind(i)),c{i,1},c{i,2});
end
Screen('Flip',run.w(1));

function run = computePosition(ai,run)

% Set threshold discontinuity
discontinuity_thresh = 0.1;

% Noise threshold
noise_threshold = 3;

% Gain
gain = run.trial(run.trial_number).track_gain;

% Get data from daq engine
n = 0;
% tic
while n == 0
    n = get(ai,'SamplesAvailable');
end
% toc
d = getdata(ai,n);
d = d(:,1);  %  Chn0/Ind1 is absolute position encoder

% Compute distance traveled in pixels
d = diff(d);
d(abs(d) > discontinuity_thresh) = NaN;
d = nansum(d);
d = d*run.cm_per_volt*run.pixels_per_cm*gain;

p = run.p;
if run.freeze_state==0
    if abs(d) > noise_threshold
        % Compute new position
        p = fix(p - d);
        p = mod(p,run.trial(run.trial_number).trk.length);
    else
        d = 0;
    end
    
elseif run.freeze_state>0
    if abs(d) > noise_threshold
        % Compute new position
        run.pfreeze = fix(run.pfreeze - d);
        run.pfreeze = mod(run.pfreeze,run.trial(run.trial_number).trk.length);
        d=0;
    else
        d = 0;
    end
end

p(p==0) = 1;

run.p = p;
run.distance = run.distance + d;

function clearDaq(ai,run)
run = computePosition(ai,run);

function velocity = computeVelocity(ai,run)
clearDaq(ai,run);
for i = 1:3
    run = computePosition(ai,run);
    d(i) = run.distance;
    
    if i < 3
        WaitSecs(trk.track_update_interval);
    end
end

d = diff(d)/2/run.track_update_interval;  % pixels/s
velocity = d*run.cm_per_pixel;

function run = computeContingencies(run,ai)

c_obj_ind = run.p_mat(5,run.p);
obj = run.trial(run.trial_number).trk.obj(c_obj_ind);

% Determine LED status
if run.use_led
    run = assessLED(run,obj);
end

%Determine if need to freeze stimulus
if run.freeze_flag
    if isnan(run.trial(run.trial_number).p1(c_obj_ind))||isnan(run.trial(run.trial_number).p2(c_obj_ind))
        run = freezeStimulus(run,obj,c_obj_ind);
    end
end

if run.distance-run.distance_last_reward > 0.7*run.trial(run.trial_number).trk.length
    obj.reward_available = 1;
    run.trial(run.trial_number).trk.obj(c_obj_ind) = obj;
end

if obj.target && obj.reward_available && run.p <= obj.target_zone(1) && run.p >= obj.target_zone(2)
    run.time_in_reward_zone = run.time_in_reward_zone + toc(run.tic_hold_time);
else
    run.time_in_reward_zone = 0;
end

% % Hold time warm up
% if run.n_rewards < 4 
%     time_hold = 0.6;
% elseif run.n_rewards <  8
%     time_hold = 0.7;
% elseif run.n_rewards < 12
%     time_hold = 0.8;
% else
%     time_hold = run.trial(run.trial_number).time_hold_for_reward;
% end

time_hold = run.trial(run.trial_number).time_hold_for_reward;

if obj.target && obj.reward_available && run.time_in_reward_zone > time_hold
    %     run.time_in_reward_zone
    %     tic
    putvalue(run.lick_port.parentuddobj,1,1);
    %     toc
    %     tic
    WaitSecs(run.trial(run.trial_number).solenoid_open_time);
    %     toc
    %     tic
    putvalue(run.lick_port.parentuddobj,0,1);
    %     toc
    
    run.distance_last_reward = run.distance;
    obj.reward_available = 0;
    
    run.n_rewards = run.n_rewards + 1;
    disp(['rewards = ' num2str(run.n_rewards)])
    run.reward_data(run.n_rewards).time_in_session = toc(run.tic_session_start);
    run.reward_data(run.n_rewards).time_in_trial = toc(run.tic_trial_start);
    run.reward_data(run.n_rewards).trial_number = run.trial_number;
    run.reward_data(run.n_rewards).position = run.p;
    run.reward_data(run.n_rewards).target_object = c_obj_ind;
    run.reward_data(run.n_rewards).hold_time = run.time_in_reward_zone;
    
    run.trial(run.trial_number).trk.obj(c_obj_ind) = obj;
    
    run.time_in_reward_zone = 0;
    clearDaq(ai,run);
end

function run = assessLED(run,obj)

for i = 1:length(obj.led_on)
    if obj.led_on(i) && run.p <= obj.led_zone(1) && run.p >= obj.led_zone(2)
        % LED+ object and in LED zone and LED is not on, then turn on
        if ~run.led_state(i)
            run.led_state(i) = 1;
            % Turn on LED
            putvalue(run.led(obj.led_on(i)).parentuddobj,1,i+1);
        end
    elseif run.led_state(i)
        % Turn off LED
        run.led_state(i) = 0;
        putvalue(run.led(i).parentuddobj,0,2);
    end
end

function run = freezeStimulus(run,obj,i)
    if isnan(run.trial(run.trial_number).p1(i)) && run.p <= (obj.center+1100)&& run.p>1  %1100
        run.trial(run.trial_number).p1(i)=run.p;
        run.pfreeze=run.p;
        run.p=obj.center+600;
        run.freeze_state=tic;
    elseif isnan(run.trial(run.trial_number).p2(i)) && ~isnan(run.trial(run.trial_number).p1(i))
        if toc(run.freeze_state)>0.35
            run.freeze_state=0;
            run.trial(run.trial_number).p2(i)=run.pfreeze;
        end
    end


function waitForUpdateInterval(run)
if toc(run.tic_update) < run.track_update_interval
    WaitSecs(run.track_update_interval-toc(run.tic_update));
end

function trigger_time = triggerDaq(run)
p_port = run.p_port;
if run.parallel_port_trigger
    trigger_time = toc(run.tic_session_start);
    putvalue(p_port.parentuddobj,[p_port.bitOn p_port.bitOff],p_port.triggerLine)
    WaitSecs(0.0001);
    putvalue(p_port.parentuddobj,[p_port.bitOff p_port.bitOff],p_port.triggerLine)
end

function [session_active tic_keyCheck] = keyCheck(session_active)
tic_keyCheck = tic;
[key_pressed, junk, key] = KbCheck;
if key_pressed && find(key) == 8
    session_active = 0;
end

function  c = computeCoordinates(p,p_mat,sw,tile_w,trk_h)
% p:
% p_mat:
% sw: screen_width
% tile_w: tile_width
% trk_h: track height

% Coordinates of tile 1
t1_left = mod(p-1,tile_w);
t1_right = tile_w;
t1_w = t1_right - t1_left;
c{1,1} = [t1_left 0 t1_right trk_h];
c{1,2} = [0 0 t1_w trk_h];

% Coordinates of tile 2
t2_left = 0;
t2_right = sw-t1_w;
t2_right(t2_right>tile_w) = tile_w;
t2_w = t2_right - t2_left;
c{2,1} = [t2_left 0 t2_right trk_h];
c{2,2} = [t1_w 0 t1_w+t2_w trk_h];

% Coordinates of tile 3
t3_left = 0;
t3_right = sw-t1_w-t2_w;
t3_right(t3_right>tile_w) = tile_w;
t3_w = t3_right - t3_left;
c{3,1} = [t3_left 0 t3_right trk_h];
c{3,2} = [t1_w+t2_w 0 t1_w+t2_w+t3_w trk_h];

function saveRunData(run,mouse)
if run.save_run
    run = rmfield(run,{'p_mat','lick_port'});
    if run.parallel_port_trigger
        run = rmfield(run,{'p_port'});
    end
    if run.use_led
        run = rmfield(run,{'led'});
    end
    save(mouse.vtrack.session(mouse.vtrack.session_ind).run_file,'run')
end

function mouse = finalSave(run,mouse)
if run.save_run
    rdef = RigDefs;
    run = rmfield(run,{'p_mat','lick_port'});
    if run.parallel_port_trigger
        run = rmfield(run,{'p_port'});
    end
    if run.use_led
        run = rmfield(run,{'led'});
    end
    
    % Save run file on analysis PC
    [junk fname] = fileparts(mouse.vtrack.session(mouse.vtrack.session_ind).run_file);
    fname = [rdef.Dir.vTrackData fname];
    fname = checkIfFileExists(fname);
    run.file = fname;
    saveRun(run);
    
    % Set new run file in mouse struct and save
    mouse.vtrack.session(mouse.vtrack.session_ind).run_file = run.file;
    saveMouse(mouse);
end

function mouse = endTrack(ai,run,mouse,psychlasterror)

% Session ends now
run.session_end_time = datestr(now);

% Could deal with this in another way
run.trial_number = run.trial_number - 1;

% Delete ai
stop(ai)
delete(ai);

% Delete udp object
if isfield(run,'u');
    fclose(run.u);
    delete(run.u);
    run = rmfield(run,'u');
end

% Delete parallel port dio
if run.parallel_port_trigger
    delete(run.p_port.dio);
end


% Delete LED dio
if run.use_led
    for i = 1:length(run.led)
        putvalue(run.led(i).parentuddobj,0,i+1);
    end
    %     delete(run.led.dio);
end

% Delete lickport dio
delete(run.lick_port.dio);

% Error?
if ~isempty(psychlasterror)
    psychrethrow(psychlasterror);
end

% Screen clean-up
Priority(0);
ShowCursor
Screen('CloseAll');
if isfield(run,'tx')
    Screen('Close',run.tx);
end
clear mex

putvar(run)

% Save
saveRunData(run,mouse)
mouse = finalSave(run,mouse);

function value = getFromTable(table,field)

iRow = strcmp(table(:,1),field);

if any(iRow)
    value = table(iRow,2);
    if iscell(value)
        value = value{1};
    end
else
    %     disp(['The field,' ' ' field ', was not found in table'])
    value = '';
end

function displayCue
%             tile_ind = p_mat(2:end,p);
%             c = computeCoordinates(p,p_mat,screen_width,trk.tile_width,trk.width);
%             for i = 1:3
%                 Screen('DrawTexture',w,tx(tile_ind(i)),c{i,1},c{i,2});
%             end
%             Screen('Flip',w);
%
%             putvalue(dio.Line(1),1);
%             short_open = solenoidShort;
%             WaitSecs(short_open);
%             putvalue(dio.Line(1),0);
%             WaitSecs(1.5-short_open);
%             %             WaitSecs(1.25);


function run = udpSetup(run)

if run.parallel_port_trigger;
    rdef = RigDefs;
    if ~isempty(rdef.DAQPC_IP)
        % Look for valid udp
        bnewudp = 0;
        props = {'Tag','Type'};
        vals = {'udp_conditions','udp'};
        u = instrfindall(props,vals);
        delete(u);
        if ~isempty(u)
            if ~isvalid(u);
                delete(u);
                bnewudp = 1;
            end
        else
            bnewudp = 1;
        end
        
        % If valid upd doesn't exist create it
        if bnewudp
            u = udp(rdef.DAQPC_IP,9093,'LocalPort',9094);
            u.Tag = 'udp_conditions'; % Tag for finding object later
        end
        
        if ~isequal(u.Status,'open');
            fopen(u);
        end
    end
    
    run.u = u;
end

function run = syncDaqPulse(run)

pulse_period = 200;
i = size(run.sync_daq,1)+1;
if mod(run.update_index,pulse_period) == 1
    run.sync_daq(i,1) = run.update_index;
    run.sync_daq(i,2) = triggerDaq(run);
    run.sync_daq(i,3) = run.p;
end





