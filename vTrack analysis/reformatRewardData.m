function run = reformatRewardData(run)
%
%
%
%
%

% Created: SRO - 6/21/12




rd = run.reward_data;
fld = fields(rd);


for i = 1:length(fld)
    tmp = {rd.(fld{i})};
    tmp = cell2mat(tmp);
    rd_new.(fld{i}) = tmp;
end

run.rd = rd_new;

