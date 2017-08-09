function r = addChoiceData(r)
%
% INPUT
%   r: run struct
%
%

% Created: SRO - 2/9/13


obj = r.obj_trk.obj;

holdTime = r.trial(1).time_hold_for_reward;
for i = 1:length(obj)   
    
    obj(i).choice = obj(i).time_in_zone >= holdTime;
        
end

r.obj_trk.obj = obj;



