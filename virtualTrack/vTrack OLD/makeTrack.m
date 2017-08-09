function [run trk] = makeTrack(run,trk)
%
%
%
%
%

% Created: SRO - 3/31/12
% Modified: SRO - 5/26/12

% Set screen defaults
sdef = screenDefs;

% Define obj struct
obj = run.trial(run.trial_number).obj;

% Compute track length
tl = 0;
for i = 1:length(obj)
    tl = tl+obj(i).size+obj(i).buffer_left+obj(i).buffer_right;
end

nTiles = ceil(tl/sdef.width);
tileWidth = ceil(tl/nTiles);
tl = nTiles*tileWidth;

% Preallocate track
trk_height = sdef.height;
trk_m = ones(trk_height,tl);

% Make track backgound
trk_m = run.trial(run.trial_number).background_pix_val*trk_m;

% Set solenoid open time
run = computeSolenoidOpenTime(run);

% Make objects
for i = 1:length(obj)
    trk_m = addObjectToTrack(trk_m,obj(i));
    obj(i).tile_width = tileWidth;
end

% Make position matrix
p = 1:size(trk_m,2);
p(2,:) = floor(p(1,:)/tileWidth)+1;
p(3,:) = mod(p(2,:),nTiles)+1;
p(4,:) = mod(p(2,:)+1,nTiles)+1;
p_mat = p;

for i = 1:length(obj)
    tmp = all([p(1,:) >= obj(i).panel_left; p(1,:) <= obj(i).panel_right]);
    p_mat(5,tmp) = i;
end

% Close previous textures
if isfield(run,'tx')
    Screen('Close',run.tx);
    %     disp('Previous textures closed')
end

% Make track texture tiles
for i = 1:nTiles
    startPt = (i-1)*tileWidth+1;
    endPt = startPt+tileWidth-1;
    trkTx(i) = Screen('MakeTexture',run.w(1),trk_m(:,startPt:endPt));
end

% Output
run.trial(run.trial_number).tx = trkTx;
run.trial(run.trial_number).tile_width = tileWidth;
run.trial(run.trial_number).n_tiles = nTiles;
run.trial(run.trial_number).length = tl;
run.trial(run.trial_number).height = trk_height;
run.trial(run.trial_number).screen_width = sdef.width;
run.trial(run.trial_number).obj = obj;
run.p_mat = p_mat;
run.trk_m = trk_m;
run.tx = trkTx;














