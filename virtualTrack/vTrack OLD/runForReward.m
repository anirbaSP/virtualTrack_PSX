function runForReward()
%
%
%
%


% --- Set paramters
gain = 0.01;
updateFreq = 40;
updateInterval = 1/updateFreq;
solenoidOpenTime = 0.15;
d_thresh = 0.18;
total_rewards = 60;
num_rewards = 0;
iti_reward = 5;
t_since_reward = 0;

% --- Define analog input
ai = aiSetup();
start(ai);
WaitSecs(0.1);

% --- Define digital outputs
daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    dio = digitalio('nidaq','Dev1');
    hwlines = addline(dio,0,'out');
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    dio = digitalio('mcc','0');
    hwlines = addline(dio,0,'out');
end

% --- Set up keys
KbName('UnifyKeyNames')

t_reward = tic;
n = 0;
while n == 0
    n = get(ai,'SamplesAvailable');
end
tmp = getdata(ai,n);


% Stay in this loop until mouse is running

while num_rewards < total_rewards  &&  ~KbCheck
    t_start = tic;
    
    
    % Compute distance traveled
    d = computeDistance(ai,gain);
    if d > d_thresh && toc(t_reward) > iti_reward
        putvalue(dio.Line(1),1);
        WaitSecs(solenoidOpenTime);
        putvalue(dio.Line(1),0);
        t_reward = tic;
        num_rewards = num_rewards + 1
    end
    
    WaitSecs(updateInterval - toc(t_start));
end

stop(ai)
Screen('CloseAll')
delete(ai);
delete(dio);



function d = computeDistance(ai,gain)
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


function ai = aiSetup()

daq = daqhwinfo;
if any(strcmp('nidaq',daq.InstalledAdaptors))
    ai = analoginput('nidaq','Dev1');
    set(ai,'SampleRate',1000,'TriggerType','Immediate','InputType','SingleEnded');
    ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
    set(ch(1),'InputRange',[-10 10]);
    set(ch(1),'SensorRange',[0 5]);
    set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire
elseif any(strcmp('mcc',daq.InstalledAdaptors))
    ai = analoginput('mcc',0);
    set(ai,'SampleRate',1000,'TriggerType','Immediate');
    ch = addchannel(ai,0);  % chn0 = position encoder; chn1 = lickometer
    set(ch(1),'InputRange',[-10 10]);
    set(ch(1),'SensorRange',[0 5]);
    set(ai,'SamplesPerTrigger',Inf);    % We will continuously acquire
else
    error('No daq device installed')
end
