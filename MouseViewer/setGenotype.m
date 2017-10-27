function genotype = setGenotype()
%
%
%
%

% Created: SRO - 5/30/12

genotype_list = {
    'C57Bl/6',
    'PV-Cre',
    'SOM-Cre',
    'Gad-Cre',
    'NTSR1-Cre',
    'Rbp4-Cre',
    'Scnn1aTg3-Cre',
    'EMX-Cre',
    'Ai32 ChR2',
    'Ai35 Arch',
    'Ai39 NpHR',
    'tdTomato',         % name?
    'GAD67-GFP',
    'Gad-ChR2'
    'CaMK2a-GCaMP6s'};

[s,v] = listdlg('PromptString','Select genotype:','ListSize',[180 300],...
    'ListString',genotype_list);

if v
    for i = 1:length(s)
        if i == 1
            genotype = genotype_list{s(i)};
        else
            genotype = [genotype ' ' '/' ' ' genotype_list{s(i)}];
        end
    end
else
    genotype = '';
end


a = 1;








