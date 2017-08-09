function run = cleanupRunPositionData(run)
%
%
%
%

% Created: SRO - 6/19/12



p = run.position_data;


% Remove NaNs from trials not completed
p(:,run.trial_number+1:end,:) = [];

% Remove place holders beyond samples acquired
k = find(~isnan(p(:,:,2)));
[m,n] = ind2sub(size(p(:,:,2)),k);
p(max(m)+1:end,:,:) = [];

% Remove incomplete trials
while sum(isnan(p(:,end,2))) > 0.25*size(p(:,end,2),1)
    p(:,end,:) = [];
end

% Update number of trials
run.trial_number = size(p,2);

% Remove extraneous trials structs
run.trial(run.trial_number+1:end) = [];

% Set new position data
run.position_data = p;

disp('***** Cleaned up RUN trial struct *****')


