function task = setTask()
%
%
%
%

% Created: SRO - 5/30/12

task_list = {
    'discrimination',
    'mismatch'
    };

[s,v] = listdlg('PromptString','Select task:','ListSize',[250 250],...
    'ListString',task_list);

if v
    for i = 1:length(s)
        if i == 1
            task = task_list{s(i)};
        else
            task = [task ' ' '/' ' ' task_list{s(i)}];
        end
    end
else
    task = '';
end

a = 1;








