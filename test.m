 
  
function test()
global temp_t
global temp_d


  s = daq.createSession('ni');   
  s.Rate=  1000;
  s.IsContinuous=true;
  s.IsNotifyWhenDataAvailableExceedsAuto = false;
  s.NotifyWhenDataAvailableExceeds=20;
  
  ch = addAnalogInputChannel(s,'Dev1', 0:2, 'Voltage');
  set(ch(1),'Range',[-10 10]);  
  set(ch(1),'TerminalConfig','Differential');
  set(ch(2),'Range',[-10 10]);  
  set(ch(2),'TerminalConfig','Differential');
  set(ch(3),'Range',[-10 10]);  
  set(ch(3),'TerminalConfig','Differential');
  
  dio=daq.createSession('ni');   
  addDigitalChannel(dio,'Dev1', 'Port0/Line0', 'OutputOnly'); 

 lh = addlistener(s,'DataAvailable', @(src,event) getData(src,event));
  temp_t=[];
  temp_d=[];
  d=[];
  n_counter=s.ScansAcquired
  s.startBackground();
  
  for k=1:2000
      
      pause(0.02);
%   while (n_counter==s.ScansAcquired)
%   end
%   flag=0;
%   while~flag
%   [d,flag]=computePosition(d);
%   end
   d
   n_counter=s.ScansAcquired
  end
  
  outputSingleScan(dio,1);
  pause(0.08);
  outputSingleScan(dio,0);
  
%   flag=0;
%   while~flag
%   %[d,flag]=computePosition(d);
%   end
  
  
  stop(s);
  stop(dio);
  delete(lh);
end

function getData(src,event)
global temp_t
global temp_d

temp_t=[temp_t; event.TimeStamps];
temp_d=[temp_d; event.Data];

end

function [d,update_flag]=computePosition(d)
%64bit daq
global temp_t
global temp_d

if (isempty(temp_t))
    
    update_flag=0;
else   
    
    update_flag=1
    d=temp_t;
    temp_t=[];
    temp_d=[];
end
end