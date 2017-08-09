function [varargout] = requiredToolboxes(mfiles, levels)
% REQUIREDTOOLBOXES   Determine what toolboxes are required to run an M-file.
%    REQUIREDTOOLBOXES(MFILES) displays the required toolboxes for the
%    specific file(s). It will default to looking 3 levels deep.
%
%    REQADDONTOOLBOXES = REQUIREDTOOLBOXES(MFILES) returns the names of the
%    required addon toolboxes.
%
%    REQUIREDTOOLBOXES(MFILES, LEVELS) searches the specified number of
%    levels of M-files for required toolboxes. A good default is 3, too
%    many and extraneous toolboxes are found, too few and required
%    toolboxes may be missed.


if nargin < 1
    mfiles = 'imshow.m';
end
if nargin < 2
    levels = 3;
end

% Get the first level of files
[files builtins classes] = depfun(mfiles,'-toponly','-quiet');
% Initial list of all required files
reqFiles = union(files, classes);
for i = 2:levels
    [files builtins classes] = depfun(files,'-toponly','-quiet');
    % Update the list of all required files
    reqFiles = union(reqFiles,union(files, classes));
end

% Parse the list of required files to determine what toolboxes they are from
reqToolboxFolders = {};
for i = 1:length(reqFiles)
    remain = reqFiles{i};

    toolbox = '';
    while true
        [str, remain] = strtok(remain, filesep);
        if isempty(str),
            break;
        end
        if strcmpi(str,'toolbox')
            toolbox = strtok(remain, filesep);
            break;
        end
    end
    if ~isempty(toolbox)
        reqToolboxFolders = union(reqToolboxFolders,toolbox);
    end
end

baseMATLABFolders = {'matlab','shared','local'};
reqAddonToolboxes = setdiff(reqToolboxFolders,baseMATLABFolders);

if nargout == 0
    if ~isempty(reqAddonToolboxes)
        disp('Required toolboxes:')
        cellfun(@disp,reqAddonToolboxes)
    else
        disp('Only base MATLAB is required')
    end
else
    if nargout >= 1
        varargout{1} = reqAddonToolboxes;
    end
    if nargout >= 2
        varargout{2} = reqFiles;
    end
end