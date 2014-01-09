function reconcileEvents(processingEvts, neuralynxEvts, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert events file and raw output from Sebastien's processing GUI
%
% Input: 
%
%   processingEvts =
%   '/Users/McCool/Dropbox/AS_Graybiel/fsm001_d2_r1/RAW_fsm001_d2_r1.txt'
%
%   neuralynxEvts =
%   '/Users/McCool/Dropbox/AS_Graybiel/fsm001_d2_r1/events.mat'
%
%   varargin if specified will allow for the following format of
%   <processingEvts> and <neuralynxEvts>. If <varargin> is empty, you
%   can still enter the following values so long as your working directory
%   has the necessary files to be converted. 
%
%   processingEvts = 'RAW_fsm001_d2_r1.txt'
% 
%   neuralynxEvts = 'events.mat'
%
% Output:
% 
%   events_reconciled.mat - an events file containing timestamps adjusted
%   to the Cheetah clock values, TTLs, and any associated VALUES.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(varargin)
    relativePath = varargin{1};
else
    relativePath = pwd;
end

% evt_fLoc = '/Users/McCool/Dropbox/AS_Graybiel/fsm001_d2_r1/';
% proc_evt_fName = 'RAW_fsm001_d2_r1.txt';
% processingEvents = load([evt_fLoc proc_evt_fName]);
processingEvents = load([relativePath filesep processingEvts]);

if any(diff(processingEvents(:,1)) < 0)
    % oddly ... there is a switch to negative timestamps ... 32 bit reserved
    % for sign when recording signed integers.
    % because the integers are signed instead of unsigned ... add 2^32
    negIx = find(processingEvents(:,1) < 0);
    processingEvents(negIx(1):end,1) = processingEvents(negIx(1):end,1) + 2^32;
    % add a column of relative times for the processing events
    processingEvents(:,4) = [0 diff(processingEvents(:,1))'];
    if any(diff(processingEvents(:,1)) < 0)
        warning(['Fix for timestamps did not work. Check the number of' ...
            'resets found in the data. Function needs to be updated to ' ...
            'handle this error.'])
    end 
end

% Load the Neuralynx events
% neur_evt_fName = 'events.mat';
% load(neur_evt_fName);
load([relativePath filesep neuralynxEvts]);

% proc_evt 25 (see TTL_CODES) corresponds to the clock sent out by cheetah,
% we can match the cheetah timestamps with the processing timestamps and
% align the remaining events to create a new events file.
cheetahClock_Idx = find(processingEvents(:,2) == 25);
if numel(cheetahClock_Idx) ~= size(evts,1)
    warning(['Check input files. The number of Cheetah timestamps does' ...
        ' not correspond to the number of records reported by Processing GUI'])
end

% The Cheetah timestamps are in seconds, and record the timing out to
% microsecond precision. The new events file should have just as many
% records as the Processing events file, however, the timestamps will be
% realigned to the Cheetah clock so that spike data and LFPs can be
% analyzed relative to the recorded events.
new_procTS = zeros(size(processingEvents,1),1);
new_procTTL = zeros(size(processingEvents,1),1);
new_procVAL = zeros(size(processingEvents,1),1);

% Align events relative to the first Cheetah timestamp
curIdxRange = 1:(cheetahClock_Idx(1)-1);
prevTS_offset = (processingEvents(curIdxRange,1)-...
    processingEvents(cheetahClock_Idx(1),1))./1e6;

new_procTS(curIdxRange) = evts(1,2) + prevTS_offset;
new_procTTL(curIdxRange) = processingEvents(curIdxRange,2);
new_procVAL(curIdxRange) = processingEvents(curIdxRange,3);

new_procTS(cheetahClock_Idx(1)) = evts(1,2);
new_procTTL(cheetahClock_Idx(1)) = 25;
new_procVAL(cheetahClock_Idx(1)) = ...
    processingEvents(cheetahClock_Idx(1),3);

% Loop through the remaining sections of the timestamps to complete filling
% out the adjusted timestamp variable <new_procTS>
for clockIdx = 2:length(cheetahClock_Idx)
    
    curIdxRange = ...
        (cheetahClock_Idx(clockIdx-1)+1):(cheetahClock_Idx(clockIdx)-1);
    prevTS_offset = (processingEvents(curIdxRange,1)- ...
        processingEvents(cheetahClock_Idx(clockIdx),1))./1e6;
    
    new_procTS(curIdxRange) = evts(clockIdx,2) + prevTS_offset;
    new_procTTL(curIdxRange) = processingEvents(curIdxRange,2);
    new_procVAL(curIdxRange) = processingEvents(curIdxRange,3);
    
    new_procTS(cheetahClock_Idx(clockIdx)) = evts(clockIdx,2);
    new_procTTL(cheetahClock_Idx(clockIdx)) = 25;
    new_procVAL(cheetahClock_Idx(clockIdx)) =  ...
        processingEvents(cheetahClock_Idx(clockIdx),3);
    
end

% Align the remaining recorded processing events
curIdxRange = cheetahClock_Idx(end)+1:length(new_procTS);
TS_offset = (processingEvents(curIdxRange,1)- ...
    processingEvents(cheetahClock_Idx(end),1))/1e6;

new_procTS(curIdxRange) = evts(size(evts,1),2) + TS_offset;
new_procTTL(curIdxRange) = processingEvents(curIdxRange,2);
new_procVAL(curIdxRange) = processingEvents(curIdxRange,3);

events = [new_procTS new_procTTL new_procVAL];
save events_reconciled.mat events

end