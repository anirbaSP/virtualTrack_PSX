function z = inRewardZone(p,obj)
% function inRewardZone(p,obj)
%
% z, vector same length as p, with logical values showing whether element
% in p is in reward zone of obj.
%

% Created: SRO - 6/17/12



a = 1;

z = p >= obj.target_zone(1) & p <= obj.target_zone(1);