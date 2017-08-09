function positionRaster(s)
%
%
%
%
%

% Created: SRO - 2/14/13




% Remove NaNs from spikes struct
s.tmp = isnan(s.encounter_number);
s = filtspikes(s,0,'tmp',0);

% 
% Set y values
enc_numbers = unique(s.encounter_number);
for i = 1:length(enc_numbers)
   y(s.encounter_number == enc_numbers(i)) = i;
end

h.raster = linecustommarker(s.position_rel,y);

a = 1;
