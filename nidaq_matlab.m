%%% NIDAQ script for Takaki K. August 9,2009
% My board: NI USB-6259. Need Data Acquisition Toolbox.

%% get the device name
hw = daqhwinfo('nidaq') 

%% Analog input
recording_time=600; %in sec
ai = analoginput('nidaq','Dev2') % create analog input object
ich = addchannel(ai, [1:2]) % add channels you'll record from
set(ai,'SampleRate',1000)
ActualRate = get(ai,'SampleRate');
set(ai,'SamplesPerTrigger',recording_time*ActualRate)
set(ai,'InputType', 'SingleEnded') 
set(ai,'ChannelskewMode','Equisample')
Fs = ActualRate;

start(ai)
% wait as long as you wish to record.

stop(ai)
%retrieve data and visualize it 
f =ai.SamplesAvailable
d=getdata(ai,f);
figure
plot((1:length(d))/Fs,d,'-k');


%% Analog output
ao = analogoutput('nidaq','Dev2') % create analog  output object
och = addchannel(ao, 0)
set(ao,'SampleRate',1000)
ActualRate = get(ao,'SampleRate');

% set channel high. my board needs at least 3 samples for this.
a0=5*ones(3,1)
putdata(ao,a0);
start(ao);
while strcmp(ao.Running,'On') % wait for ao to finish, sort of useful during expt.
end

% wait as long as you wish here.

% set channel low.
a0=0*ones(3,1)
putdata(ao,a0);
start(ao);


%% Digital input/output
% My water valve calibration routine
% FV: set up in port 0, line 0 
% WV: set up in port 0, line 1
dio = digitalio('nidaq','Dev2');
addline(dio,0:1,'out'); %set as output or input
putvalue(dio,0); %set them low

% dispensing water
t_wv = 0.04; % time that solenoid is open (sec)
t_wait=1; %wait between drops
for k =1:210
    k
    t0 = cputime;
    putvalue(dio,[0 1]);
    while ((cputime - t0) <=t_wv)
    end
    putvalue(dio,0);
    while ((cputime - t0) <=t_wait)
    end
    %pause
end











