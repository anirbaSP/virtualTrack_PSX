function objPool = makeObjectPool(obj)

% So far only the following case is implemented:

% obj.type = 1 and the folowing field keeps the same for all objects:
% size
% background_pix_val
% contrast
% rect

% by PSX 09/2017

angle = unique([obj.angle]); % In my case only angle will change

objPool = struct;
for i = 1:length(angle)
    this_angle = angle(i);
    this_size = obj(1).size;
    this_background_pix_val = obj(1).background_pix_val;
    this_contrast = obj(1).contrast;
    
    tmp = mkGrating(this_size,this_background_pix_val,this_angle,this_contrast);
    tmp = double(tmp);
    
    objPool(i).tmp = tmp;
    objPool(i).angle = this_angle;
    objPool(i).size = this_size;
    objPool(i).background_pix_val = this_background_pix_val;
    objPool(i).contrast = this_contrast;
end

