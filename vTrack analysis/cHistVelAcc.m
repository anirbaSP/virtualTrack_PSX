function cHistVelAcc(run,trials)
%
%
%
%

% Created: SRO - 6/20/12


if nargin < 2 || isempty(trials)
   trials = 1:run.trial_number;
end


p = run.position_data(:,trials,2);
v = run.position_data(:,trials,3);
a = run.position_data(:,trials,4);

bins = 0:100:run.trial(1).trk.length;

p_all = [];
v_all = [];
a_all = [];
for i = 1:length(bins)-1;
    tmp = p >= bins(i) & p < bins(i+1);
    p_all = [p_all; p(tmp)];
    v_all = [v_all; v(tmp)];
    a_all = [a_all; a(tmp)];
    
    v_q(i,:) = quantile(v(tmp),[.25 .50 .75]); 
    a_q(i,:) = quantile(a(tmp),[.25 .50 .75]); 
    
    v_m(i,:) = [mean(v(tmp)) std(v(tmp))]; 
    a_m(i,:) = [mean(a(tmp)) std(a(tmp))]; 

end

a = 1;

