function sessionInd = findRunSession(run,mouse)
%
%
%
%

% Created: SRO - 6/23/12



s = mouse.vtrack.session;

for i = 1:length(s)
    
   r_file = s(i).run_file;
   tmp = strfind(r_file,'\');
   r_file(1:tmp(end)) = [];
   
   if strcmp(run.name,r_file)
       sessionInd = i;
       break
   end
   
end