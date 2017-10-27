function virus = setVirus()
%
%
%
%

% Created: SRO - 5/30/12

virus_list = {
    'AAV2/9.CAGGS.flex.ChR2.tdTomato.SV40',
    'AAV2/9.CaMKII.ChR2-YFP.SV40',
    'AAV2/1.EF1a.D10.eNpHR3.0-EYFP-WPRE',
    'AAV2/1.CAG.ArchT-GFP',
    'AAV2/9.flex.CBA.Arch-GFP.W.SV40',
    'AAV2/1.flex.CBA.Arch-GFP.W.SV40',
    'none'};

[s,v] = listdlg('PromptString','Select virus:','ListSize',[250 250],...
    'ListString',virus_list);

if v
    for i = 1:length(s)
        if i == 1
            virus = virus_list{s(i)};
        else
            virus = [virus ' ' '/' ' ' virus_list{s(i)}];
        end
    end
else
    virus = '';
end

a = 1;








