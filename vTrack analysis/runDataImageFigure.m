function runDataImageFigure(run)
%
%
%
%
%
%

% Created: SRO - 6/10/12



% Get position struct
p = run.position_data;

% Remove trials not completed
pos = p(:,:,2);
pos_t = p(:,:,1);


pos(:,run.trial_number:end) = [];
pos_t(:,run.trial_number:end) = [];

ind = isnan();

