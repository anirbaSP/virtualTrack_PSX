function trk = makeTrackObjects(trk,trial_number)
%
% Notes: objects: 1, square; 2, 
%
%

% Created: SRO - 3/31/12
% Modified: SRO - 5/25/12

sdef = screenDefs;

% background_pix_val = lum2pixVal(trk.background_luminance);
background_pix_val = 112; %AR changed this from 100 to 112
screenRect = [0 0 sdef.width sdef.height];

objTypes = trk.objects;      
objLum = trk.objects_contrast;
objSize = trk.object_size;
objSpacing = trk.object_spacing;

for i = 1:length(objTypes)
    obj(i).pix_val = objLum(i);            
    obj(i).background_pix_val = background_pix_val;
    obj(i).size = objSize;
    obj(i).type = objTypes(i);
    [obj(i).rect j1 j2] = CenterRect([0 0 obj(i).size obj(i).size],screenRect);
    obj(i).top = obj(i).rect(2);
    obj(i).bottom = obj(i).rect(4);
    obj(i).buffer_left = objSpacing;
    obj(i).buffer_right = objSpacing;
end

trk.obj = obj;





