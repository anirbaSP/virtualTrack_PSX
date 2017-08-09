
function setMouseTable(mouse,handles)

flds = fieldnames(mouse);
for i = 1:length(flds)
   if isstruct(mouse.(flds{i}))
       mouse = rmfield(mouse,flds{i});
   end
    
end
flds = fieldnames(mouse);
values = struct2cell(mouse);
m_table = [flds values];
if length(m_table) < 100
    for i = length(m_table)+1:100
        m_table{i,1} = '';
        m_table{i,2} = '';
    end
end
set(handles.table_mouse,'Data',m_table);