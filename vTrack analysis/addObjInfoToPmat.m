function r = addObjInfoToPmat(r)
%
%
%
%

% Created: SRO - 2/14/13



pmat = r.position_data;

obj_type_mat = NaN(size(pmat(:,:,1)));
obj_center_mat = NaN(size(pmat(:,:,1)));
encounter_number_mat = NaN(size(pmat(:,:,1)));

encounter_number = 0;
for i = 1:length(r.trial)
    trk = r.trial(i).trk;
    
    p = pmat(:,i,2);
    
    for n = 1:length(trk.obj_centers)
        obj_type = trk.obj_list(n);
        obj_center = trk.obj_centers(n);
        obj_panel = [r.trial(i).trk.obj(n).panel_left ...
            r.trial(i).trk.obj(n).panel_right];
        k = (p <= obj_panel(2)) & (p >= obj_panel(1));
        obj_type_mat(k,i) = obj_type;
        obj_center_mat(k,i) = obj_center;
        
        if trk.obj_encountered(n)
            encounter_number = encounter_number + 1;
            encounter_number_mat(k,i) = encounter_number;
        end
    end
    
end

pmat(:,:,6) = obj_type_mat;
pmat(:,:,7) = obj_center_mat;
pmat(:,:,8) = encounter_number_mat;


r.position_data = pmat;

