function mouse = makeMouseStruct(mouse_table)
%
%
%
%

% Created: SRO - 5/30/12

if nargin < 1 || isempty(mouse_table)
    new_mouse = 1;
else
    new_mouse = 0;
end

if new_mouse
    % User input fields
    mouse.mouse_code = setMouseCode();
    mouse.file = setMouseFile(mouse);
    mouse.genotype = setGenotype();
    mouse.birth = setBirth();
    mouse.virus = setVirus();
    mouse.task = setTask();
    
    %
    mouse.cage_number = '';
    mouse.cage_code = '';
    mouse.ear_code = '';
    mouse.sex = '';
    mouse.injection_date = '';
    mouse.headplate_date = '';
    mouse.water_begin_date = '';
    mouse.mass_baseline = '';
    mouse.mass_current = '';
    mouse.cage_mates = '';
    mouse.purpose = '';
    
    
else
    
    % Remove empty field from table
    a = 1;
    
    
    
end

    % Save struct
    save(mouse.file,'mouse');
    
    
function mouse_code = setMouseCode()
prompt = {'Enter mouse code:'};
dlg_title = 'Make new mouse';
num_lines = 1;
mouse_code = inputdlg(prompt,dlg_title,num_lines);
mouse_code = mouse_code{1};






