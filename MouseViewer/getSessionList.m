function str = getSessionList(mouse)



str = {''};
% s_table = makeSessionTable(mouse);
[mouse s_table] = getSessionTable(mouse);

for m = 1:size(s_table,1)
    tmp = [];
    for n = 1:size(s_table,2)
        if n > 1
        tmp = [tmp ' -- ' s_table{m,n}];
        else 
            tmp = s_table{m,n};
        end
    end
    str{m} = tmp;
end

% % Show most recent files first (Currently list is reversed in
% makeSessionTable)
% str = str(end:-1:1);