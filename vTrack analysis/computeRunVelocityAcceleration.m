function run = computeRunVelocityAcceleration(run,smooth_v,smooth_a)
%
%
%
%
%

% Created: SRO - 6/19/12

if nargin < 2 || isempty(smooth_v)
    smooth_v = 13;
end

if nargin < 3 || isempty(smooth_a)
    smooth_a = 7;
end

% Set position data
p = run.position_data;

% Add NaN at end of track to prevent discontinuity
tmp = p(:,:,2);
for i = 1:size(tmp,2)
    ind = abs(diff(tmp(:,i))) > 2000;
    tmp(ind,i) = NaN;
end
p(:,:,2) = tmp;

% Take difference
for m = 1:size(p,3)
    for n = 1:size(p,2)
    dp(:,n,m) = diff(p(:,n,m));
    end
end

% dx/dt
dt = dp(:,:,1);
dp = -1*dp(:,:,2)./dt;
dp = [NaN(1,size(dp,2)); dp];

% Remove values > 100 cm/s
dp_cm = pixToCm(dp,run);
dp(dp_cm > 100) = NaN;
dp(dp_cm < -20) = NaN;

% Smooth velocity
for i = 1:size(dp,2)
   dp(:,i) = smooth(dp(:,i),smooth_v); 
end

% Compute acceleration
for i = 1:size(dp,2)
    a = diff(dp);
end

% dv/dt
a = a./dt;
a = [NaN(1,size(a,2)); a];

% Smooth acceleration
for i = 1:size(a,2)
   a(:,i) = smooth(a(:,i),smooth_a); 
end

p(:,:,3) = dp;
p(:,:,4) = a;
run.position_data = p;

disp('***** Added velocity and acceleration to RUN struct *****')
