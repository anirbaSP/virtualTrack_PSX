function trk = setObjCodes(trk)
%
%
%
%

% Created: SRO - 6/17/12




for i = 1:length(trk.obj)
    for n = 1:length(trk.code.order)
        str = trk.code.order{n};
        str = str(findstr('_',str)+1:end);
        tmp(n) = trk.obj(i).(str);
    end
    trk.obj(i).code = findMatchingRow(trk.code.params,tmp);
    
    trk.obj_list(i) = trk.obj(i).code;
    trk.obj_centers(i) = trk.obj(i).center;
end


