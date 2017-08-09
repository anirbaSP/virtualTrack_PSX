function run = findRestPeriods(run,rest_dur)
%
%
%
%
%

% Created: SRO - 6/21/12


if nargin < 2 || isempty(rest_dur)
    rest_dur = 2*20;    % Define rest bout as period of 2 s without moving (2s*20Hz update rate);
end

% Set velocity matrix
v = run.position_data(:,:,3);

% --- Identify periods of rest

% Make logical matrix in which value = 1 for velocity ~ 0 (< 25 pixels/s)
x = abs(v) < 25;
x = x';

% Compute number of consecutive v < 25
[m,n] = size(x);
y = [zeros(1,m); x'; zeros(1,m)];
p = find(~y);
y(p) = [0; 1-diff(p)];
y = reshape(cumsum(y),[],m).';
y(:,1) = [];
y(:,end) = [];
y = y';

% Define rest periods
y = y > rest_dur;

run.position_data(:,:,5) = y;

disp('***** Rest periods added to RUN struct *****')
