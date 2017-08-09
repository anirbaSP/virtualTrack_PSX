function [mouse s_table] = makeSessionTable(mouse)
%
%
%
%
%

% Created: SRO - 6/11/12


% Get session struct


s = mouse.vtrack.session;

if isempty(s)
    s_table = '';
    
else
    for i = 1:length(s)
        try
            % Load run struct
            if exist(s(i).run_file,'file')
                r = loadvar(s(i).run_file);
            else
                rdef = RigDefs;
                tmp = s(i).run_file;
                if ismac
                    tmp(findstr('\',tmp)) = '/';
                end
                [run_dir fname] = fileparts(tmp);
                r = loadvar([rdef.Dir.vTrackData fname '.mat']);
            end
            
            % Run tag
            run_tag = fname(findstr(fname,'RUN')+4:end);
            s_table{i,1} = [datestr(s(i).date,6) ' R' run_tag];
            
            % Number of trials
            s_table{i,2} = num2str(r.trial_number);
            
            % Fraction targets acquired
            s_table{i,3} = '';
            
            % Number of rewards
            s_table{i,4} = num2str(r.n_rewards);
            
            % Volume water acquired
            vol_per_reward = r.trial(1).reward_volume/1000; % For now reward same across trials
            s_table{i,5} = num2str(r.n_rewards*vol_per_reward,2);
            
            % Duration of run in minutes
            if r.trial_number > 1
                trial_time = r.trial(r.trial_number-1).start_time/60;
            else
                trial_time = r.trial(r.trial_number).start_time/60;
            end
            % Temporary
            s_table{i,6} = num2str(trial_time,3);
            
            % Average speed in cm/s
            d = r.trial(1).track_gain*r.distance/r.pixels_per_cm/trial_time/60;
            s_table{i,7} = num2str(d,2);
            
            % Hold time for reward
            hold_time = r.trial(1).time_hold_for_reward;
            s_table{i,8} = num2str(hold_time,2);
            
        catch
            
            s_table{i,1} = '';
            s_table{i,2} = '';
            s_table{i,3} ='';
        end
        
    end
    
end

% Show most recent runs first
s_table = flipdim(s_table,1);

mouse.vtrack.session_table = s_table;
saveMouse(mouse);