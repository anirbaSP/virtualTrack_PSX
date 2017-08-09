function fld = getTrkCodeFields(trk)
%
%
%
%

% Created: SRO - 6/22/12

fld = trk.code.order;

for i = 1:length(fld)
    tmp = strfind(fld{i},'_');
    fld{i} = fld{i}(tmp+1:end);
end