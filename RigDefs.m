function RigDef = RigDefs()
%
% OUTPUT
%   RigDef: Struct containing rig specific information 

%%% --- Enter rig specific values in right column --- %%%
% Computer IP addresses
RigDef.DAQPC_IP                            = '132.239.203.238';
RigDef.StimPC_IP                           = '132.239.203.238'; %'132.239.203.98'; %AR on 3/29/15
% User equipment
RigDef.equipment.amp                       = 'A-M Systems 3600';
RigDef.equipment.adaptorName               = 'nidaq';   
RigDef.equipment.board.ID                  = 'PCIe-6259';
RigDef.equipment.board.numAnalogInputCh    = 32;
RigDef.equipment.board.device              = 'Dev1';
assert(RigDef.equipment.board.numAnalogInputCh > 1, 'Error: RigDef.equipment.board.numAnalogInputCh must be > 1.');

% User ID (e.g. SRO for Shawn R. Olsen)
RigDef.User.ID                             = 'AR';
% Directories
RigDef.Dir.Data                            = '';          % Store raw .daq data files
RigDef.Dir.Spikes                          = ''; % spike sorting
RigDef.Dir.Expt                            = '';  % Important. Define experiment details.
RigDef.Dir.FigOnline                       = '';
RigDef.Dir.Settings                        = 'C:\SRO DATA\Code\Settings\DAQ PC\';  % Default configuration for Daq board
RigDef.Dir.VStimLog                        = 'C:\Users\Arbora\Documents\MATLAB\'; %'\\132.239.203.98\CODE Visual Stimulation\VStimLog\'; %AR on 3/29/15

% Virtual Track
RigDef.Dir.vTrackSettings                  = 'C:\Users\Arbora\Documents\MATLAB\virtualTrack\Settings\';
RigDef.Dir.Mouse                           = 'C:\Users\Arbora\Documents\MATLAB\Mouse\'; %'Z:\Arbora\Documents\MATLAB\Mouse\';
RigDef.Dir.vTrackDataLocal                 = 'C:\Users\Arbora\Documents\MATLAB\RunLogs\';
RigDef.Dir.vTrackData                      = 'Z:\Arbora\Documents\MATLAB\RunLogs\';% %server 'C:\Users\Arbora\Documents\MATLAB\RunLogs\'; %

RigDef.Dir.CodeRoot                        = 'C:\Users\Arbora\Documents\MATLAB\';
RigDef.Dir.Icons                           = [RigDef.Dir.CodeRoot, 'GuiTools\Icons\'];

% Making sure all the directories exist: (goes after all dirs)
% (N.B. network drives that are not accessible may take a very long time)
directories = fieldnames(RigDef.Dir);
missing = '';
for idx = 1:length(directories)
    fldname      = directories{idx};
    dirToCheck   = getfield(RigDef.Dir, fldname);    
    if(~exist(dirToCheck, 'dir'))
        missing = [missing , sprintf('\n'), dirToCheck];
    end
end
% assert(isempty(missing), sprintf('Error: Some directories defined in RigDefs.m are missing:%s\nPlease ensure RigDefs.m is up-to-date.', missing));    
% End Directories

% Prefix for daq file save names
RigDef.SaveNamePrefix                      = RigDef.User.ID;            % Can enter your own string if you want.
% Defaults for DaqController GUI
RigDef.Daq.SweepLength                     = 2.6;                       % in seconds
RigDef.Daq.TriggerRepeat                   = 4;
RigDef.Daq.TriggerFcn                      = '@DataViewerCallback';     % Use '@DataViewerCallback' unless you've developed your own online plotting callback
RigDef.Daq.SamplesAcquiredFcn              = '@DataViewerSamplAcqCallback'; 
RigDef.Daq.TimerFcn                        = '';
RigDef.Daq.StopFcn                         = '';
RigDef.Daq.OnlinePlotting                  = 'DataViewer';              % Flag to generate DataViewer GUI
RigDef.Daq.SampleRate                      = 20000;
RigDef.Daq.Gain                            = 10000;
RigDef.Daq.Filter                          = [1 5000];
RigDef.Daq.Position                        = [1478 1007];                % Position of DaqController (2 element vector [left bottom] in pixels)
% Defaults values for DataViewer GUI
RigDef.DataViewer.Position                 = [544 128 928 1023];          % Position of DataViewer ([left bottom width height] in pixels)
RigDef.DataViewer.AnalysisButtons          = 1;
RigDef.DataViewer.UsePeakfinder            = 1;                         % Default setting as to whether to use Peakfinder (1) or hard threshold (0) in detecting spikes for DAQ dataviewer
RigDef.DataViewer.ShowAllYAxes             = 1;                         % Default setting for whether to show all Y axes in DAQ dataviewer
RigDef.ExptDataViewer.ShowAllYAxes         = 0;                         % Default setting for whether to show all Y axes in EXPT dataviewer
RigDef.ExptDataViewer.UsePeakfinder        = 1;                         % Default setting as to whether to use Peakfinder (1) or hard threshold (0) in detecting spikes for EXPT dataviewer
RigDef.ExptDataViewer.DefaultThreshold     = -15;                      % Default threshold 
% Defaults for PlotChannel GUI
RigDef.PlotChooser.LPcutoff                = 200;                          
RigDef.PlotChooser.HPcutoff                = 200;
RigDef.PlotChooser.Position                = [1478 627];                % Position of PlotChooser ([left bottom] in pixels)
% Defaults for ExptTable GUI
RigDef.ExptTable.Position                  = [1478 123];        % Position of ExptTable  ([left bottom] in pixels)
RigDef.ExptTable.MarkPanel                 = 1;
RigDef.ExptTable.TimeStrings               = {'Begin @','Anesthesia @','Craniotomy @','Inserted probe @','Start recording @','End @'};
% Defaults for ExptViewer GUI
RigDef.ExptViewer.Position                 = [5 398];                 % Position of PlotChooser ([left bottom] in pixels)
% Defaults for probe
RigDef.Probe.Default                       = '16 Channel 1x16';          % Probe list in PlotChannel:  '16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode', 'Other'
RigDef.Probe.UserProbes                    = {'16 Channel 2x2', '16 Channel 1x16', '16 Channel 4x1', 'Glass electrode'};
% Defaults for channel order
RigDef.ChannelOrder                        = {[2 3 7 5 12 10 14 15 1 6 8 4 13 9 11 16 0 17]+1 ... % 2x2
                                              [16 8 15 7 12 4 13 5 10 2 9 1 11 3 14 6 0 17]+1 ... % 1x16 AM-Systems 3600 
                                              [3 6 2 1 4 5 8 7 10 9 12 13 16 15 11 14 0 17]+1 ... % 4x1
                                              [2 1 3]}; % Glass electrode
                                          
                                          %   [9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6 0 17]+1 ... % 1x16 AM-Systems 3500 
                                                                                                    
% LED defaults
RigDef.led.Enable                          = 1;  % Enable (1), disable (0) Analog/LED GUI button
RigDef.led.ID                              = {'592 nm - 7317', '590 nm - XXXX', '440 nm - XXXX'};
RigDef.led.Offset                          = {1.9,1.9,0};
RigDef.led.HwChannel                       = {0,1,2};

% Defaults SpikeSorting
RigDef.SS.label_categories = {'in process', 'good unit', 'FS good unit', 'dirty unit', 'multi-unit', 'FS multi-unit', 'garbage'};
RigDef.SS.label_colors = [ .7 .7 .7; .3 .8 .3; .3 .3 .8;  .7 .5 .5; .6 .8 .6; .6 .6 .8; .5 .5 .5];
% (TO DO NEED TO CONVERT FROM normalized to pixels, not sure how to do this
% with 2 screensRigDef.SS.default_figure_size = [.05 .1 .9 .8]; 
                                          
% --- End of user-defined rig specific paramters --- %

% Get nidaq board name
if strcmp(RigDef.equipment.adaptorName,'nidaq') && strcmp(computer,'PCWIN32')
    temp = daqhwinfo('nidaq');
    RigDef.equipment.daqboard = temp.BoardNames{1};  % Assume you only have board installed
else
    RigDef.equipment.daqboard = 'PCIe-6259';
end

% % Set DaqSetup parameters
% fName = fullfile([RigDef.Dir.Settings 'DaqSetup\'],'DefaultDaqParameters.mat');
% if isempty(dir(fName)) % make DaqSetup directory and default daq file
%     [junk pathname] = getFilename(fName);
%     parentfolder(pathname,1); % will only make top folder as it was asserted that RigDef.Dir dirs exist earlier.
%     RigDef.Daq.Parameters = createDefaultDaqParameters(fName);   
% else
%     load(fName);
%     RigDef.Daq.Parameters = Parameters;
% end
% 
% % Set ExptTable parameters
% fName = fullfile([RigDef.Dir.Settings 'ExptTable\'],'DefaultExptTable.mat');
% if isempty(dir(fName)) % make ExptTable directory, and default expttable file.
%     [junk pathname] = getFilename(fName);
%     parentfolder(pathname,1); % will only make top folder as it was asserted that RigDef.Dir dirs exist earlier.
%     RigDef.ExptTable.Parameters  = createDefaultExptTable(fName);    
% else
%     load(fName);
%     RigDef.ExptTable.Parameters = ExptTable;
% end