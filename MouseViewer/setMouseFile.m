function file = setMouseFile(mouse)
%
%
%
%

% Created: SRO - 5/31/12

rdef = RigDefs;
file = [rdef.Dir.Mouse mouse.mouse_code datestr(date,'_mmm_yyyy') '_mouse'];