function mouse = confirmRunFiles(mouse)
%
%
%
%

% Created: SRO - 6/14/12


if isfield(mouse,'vtrack')
    
    for i = 1:length(mouse.vtrack.session)
        
        r_file = mouse.vtrack.session(i).run_file;
        
        % Verify that file name has analysis PC as directory
        [r_dir fname] = fileparts(r_file);
        analysis_dir = '\\132.239.203.44\Users\shawn\vTrack Data';
        if ~strcmp(r_dir,analysis_dir)
            disp(' **** ')
            disp([' **** Wrong directory for session: RUN_' num2str(i) ' ' mouse.vtrack.session(i).date]);
            disp([' **** ' r_file]);
            
            % Determine whether file actually exists on analysis PC
            tmp = exist(fullfile(analysis_dir,[fname '.mat']));
            
            if tmp == 2
                
                disp([' **** RUN file found in dir: ' analysis_dir]);
                choice = questdlg('Change file directory in session?', ...
                    '', ...
                    'yes','no','yes');
                switch choice
                    case 'yes'
                        mouse.vtrack.session(i).run_file = fullfile(analysis_dir,fname);
                        saveMouse(mouse);
                end
            end
        end
    end
    
end
