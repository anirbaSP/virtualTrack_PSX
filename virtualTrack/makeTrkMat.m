function trk_m = makeTrkMat(trk)
%
%
%
%
%
%

% Created: SRO - 6/8/12




% Define obj struct
obj = trk.obj;

% Allocate track matrix
trk_m = single(ones(trk.height,trk.length));

% Make track background
trk_m = trk_m*trk.background_pix_value;

% PSX 09/2017 When the number of unique objects is limited and each one
% repeated appears in the track, one options to pre-made all the 
% distinctive objects, and then repeatedly use them for all the objects.

% While the original design of this part of code is put making texture in
% the addObjectToTrack function, therefore making texture repeatedly (each
% take 0.6s for large texture, accumulate to 15s for 26 objects in a track).
% Here I separate make texture out from addObjectToTrack, by
% adding a new function, namely, makeObjectPool. Call makeObjectPool first,
% and then feed the result to addObjectToTrack.

objPool = makeObjectPool(obj);

% Add objects to track
for i = 1:length(obj)
    trk_m = addObjectToTrack(trk_m,obj(i),objPool);
end
% trk_m = single(trk_m);









