function am_syncProcessing2Cheetah(dataDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert events file and raw output from Sebastien's processing GUI
%
% EX
% Input:
% dataDir = '/Users/adm/Dropbox/AS_Graybiel/q001_d1_r1';
%
% CHEETAH
% Cheetah File  :  CheetahClockEvents.mat
%
% PROCESSING
% f2cat1  :  raw_q001_20140131_2728_efr5.txt
% f2cat2  :  raw_q001_20140131_2930_efr5.txt
% f2cat3  :  raw_q001_20140131_3132_efr5.txt
% f2cat4  :  raw_q001_20140131_3334_efr5.txt
%
% Event number 25 corresponds to the timestamps being sent to cheetah in
% the Cheetah Events File
%
% Output:
% Saves one events file for each file of type "raw*.txt" found in the given
% dataDir as well as one events file containing an agglomeration of all
% events files created in the process. This script will save directly into
% the dataDir. If so desired we can update to save in a different,
% user-specified, location. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plotReport = 0;  % Can be set to 1 if a result plot is desired
% dataDir = '/Users/adm/Dropbox/AS_Graybiel/q001_d1_r1';
eval(['cd ' dataDir])

% Find files in the current working directory starting with "raw" and
% ending in ".txt", and load these files as "procFile_#". These files
% contain the timestamp information to be aligned to the information
% contained in the Cheetah Timestamp file. Generate a master file at the
% same time that contains all the processing timestamp information.

allProcessingTimestamps = [];
processingTimestampFiles = dir('raw*.txt');
fileSegments = [];

for fNum = 1:numel(processingTimestampFiles)
    eval(['procFile_' num2str(fNum) ' = load(''' ...
        processingTimestampFiles(fNum).name ''');'])
    eval(['allProcessingTimestamps = vertcat(allProcessingTimestamps,' ...
        'procFile_' num2str(fNum) ');'])
    eval(['fileSegments(end+1) = size(procFile_' num2str(fNum) ',1);'])
end

% Load the Cheetah Timestamp file as "cheetahClock", and check to see if
% the files loaded in the directory are consistent.

cheetahFile = load('CheetahClockEvents.mat');
structFields = fieldnames(cheetahFile);
eval(strcat('cheetahClock = ','cheetahFile.',structFields{1},';'))
processingEvents2Cheetah = find(allProcessingTimestamps(:,2)==25);

% Check out which of the rec segs each Cheetah call belongs to

[n, bin_cheetahEvts] = histc(processingEvents2Cheetah, ...
    horzcat(0,cumsum(fileSegments)));

% Check to make sure the files being loaded are correct, if not report an
% error, and otherwise plot a pre-final figure for examination...if so
% desired (plotReport = 1).

if length(processingEvents2Cheetah) ~= size(cheetahClock,1)
    warning('mismatchedFiles:differentLen',['Check your data directory,' ...
        ' there seems to be a different number of timestamps in the' ...
        ' Cheetah file when compared with the processing files.'])
    break
elseif plotReport == 1
    figure(1);
    subplot(2,1,1)
    [AX,H1,H2] = plotyy(1:length(processingEvents2Cheetah), ...
        allProcessingTimestamps(processingEvents2Cheetah,1), ...
        1:size(cheetahClock,1), cheetahClock(:,2));
    set(AX(1),'ylim',[0 ...
        max(allProcessingTimestamps(processingEvents2Cheetah,1))])
    set(AX(1),'xlim',[0 ...
        length(processingEvents2Cheetah)])
    set(AX(2),'ylim',[0 ...
        max(cheetahClock(:,2))])
    set(AX(2),'xlim',[0 ...
        length(cheetahClock(:,2))])
    xlabel('Cheetah Timestamp Number (1,2,3,...)')
    set(get(AX(1),'Ylabel'),'String','Processing Timestamp Value (usec)')
    set(get(AX(2),'Ylabel'),'String','Cheetah Timestamp Value (sec)')
    title('Timestamp Alignment Check')
end

% If there are no errors, proceed with aligning the timestamps from each of
% the files in the directory. Output the realigned events files in two
% different formats:
%   1: One events file being the result of concatenating of all raw*.txt
%       files contained in the directory
%   2: One separate events file for each of the raw*.txt files contained in
%       the specified directory

newProcEvents = zeros(length(processingEvents2Cheetah),3);

% Align events relative to the first Cheetah timestamp

curIdxRange = 1:(processingEvents2Cheetah(1)-1);
prevTS_offset = (allProcessingTimestamps(curIdxRange,1)-...
    allProcessingTimestamps(processingEvents2Cheetah(1),1))./1e6;

newProcEvents(curIdxRange,1) = cheetahClock(1,2) + prevTS_offset;
newProcEvents(curIdxRange,2) = allProcessingTimestamps(curIdxRange,2);
newProcEvents(curIdxRange,3) = allProcessingTimestamps(curIdxRange,3);

newProcEvents(processingEvents2Cheetah(1),1) = cheetahClock(1,2);
newProcEvents(processingEvents2Cheetah(1),2) = 25;
newProcEvents(processingEvents2Cheetah(1),3) = ...
    allProcessingTimestamps(processingEvents2Cheetah(1),3);

% Loop through the remaining sections of the timestamps to complete filling
% out the adjusted timestamp variable <new_procTS>

prevRecSeg = bin_cheetahEvts(1);
segBreaks = cumsum(fileSegments);

for clockIdx = 2:length(processingEvents2Cheetah)
    
    curRecSeg = bin_cheetahEvts(clockIdx);
    
    if curRecSeg == prevRecSeg
        curIdxRange = ...
            (processingEvents2Cheetah(clockIdx-1)+1):(processingEvents2Cheetah(clockIdx)-1);
        prevTS_offset = (allProcessingTimestamps(curIdxRange,1)- ...
            allProcessingTimestamps(processingEvents2Cheetah(clockIdx),1))./1e6;
        
        newProcEvents(curIdxRange,1) = cheetahClock(clockIdx,2) + prevTS_offset;
        newProcEvents(curIdxRange,2) = allProcessingTimestamps(curIdxRange,2);
        newProcEvents(curIdxRange,3) = allProcessingTimestamps(curIdxRange,3);
        
        newProcEvents(processingEvents2Cheetah(clockIdx),1) = cheetahClock(clockIdx,2);
        newProcEvents(processingEvents2Cheetah(clockIdx),2) = 25;
        newProcEvents(processingEvents2Cheetah(clockIdx),3) = ...
            allProcessingTimestamps(processingEvents2Cheetah(clockIdx),3);
    else
        curIdxRange = (processingEvents2Cheetah(clockIdx-1)+1):(processingEvents2Cheetah(clockIdx)-1);
        splitRangeAt = find(curIdxRange == segBreaks(prevRecSeg));
        
        % We must take care of the two segments independently
        
        thisIdxRange = curIdxRange(1:splitRangeAt);
        nextIdxRange = curIdxRange(splitRangeAt+1:end);
        
        thisTS_offset = (allProcessingTimestamps(thisIdxRange,1)- ...
            allProcessingTimestamps(thisIdxRange(1)-1,1))./1e6;
        
        newProcEvents(thisIdxRange,1) = cheetahClock(clockIdx-1,2) + thisTS_offset;
        newProcEvents(thisIdxRange,2) = allProcessingTimestamps(thisIdxRange,2);
        newProcEvents(thisIdxRange,3) = allProcessingTimestamps(thisIdxRange,3);
        
        % Next, deal with the start of the next rec seg!
        
        nextTS_offset = (allProcessingTimestamps(nextIdxRange,1)-...
            allProcessingTimestamps(processingEvents2Cheetah(clockIdx),1))./1e6;
        
        newProcEvents(nextIdxRange,1) = cheetahClock(clockIdx,2) + nextTS_offset;
        newProcEvents(nextIdxRange,2) = allProcessingTimestamps(nextIdxRange,2);
        newProcEvents(nextIdxRange,3) = allProcessingTimestamps(nextIdxRange,3);
        
        newProcEvents(processingEvents2Cheetah(clockIdx),1) = cheetahClock(clockIdx,2);
        newProcEvents(processingEvents2Cheetah(clockIdx),2) = 25;
        newProcEvents(processingEvents2Cheetah(clockIdx),3) = ...
            allProcessingTimestamps(processingEvents2Cheetah(clockIdx),3);
        
    end
    
    prevRecSeg = curRecSeg;
    
end

% Align the remaining recorded processing events

curIdxRange = processingEvents2Cheetah(end)+1:size(allProcessingTimestamps,1);
TS_offset = (allProcessingTimestamps(curIdxRange,1)- ...
    allProcessingTimestamps(processingEvents2Cheetah(end),1))/1e6;

newProcEvents(curIdxRange,1) = cheetahClock(size(cheetahClock,1),2) + TS_offset;
newProcEvents(curIdxRange,2) = allProcessingTimestamps(curIdxRange,2);
newProcEvents(curIdxRange,3) = allProcessingTimestamps(curIdxRange,3);

% Optional output

if plotReport == 1
    figure(1);
    subplot(2,1,2)
    plot(1:size(newProcEvents,1),newProcEvents(:,1),'.')
    xlabel('Processing Event Number')
    ylabel('Cheetah Aligned Timestamp')
    axis tight
end

% Save the individual results

startIdx = 1;
for recNum = 1:numel(processingTimestampFiles)
    evts =[];
    evts = newProcEvents(startIdx:segBreaks(recNum),:);
    startIdx = segBreaks(recNum)+1;
    save(strcat(processingTimestampFiles(recNum).name(1:end-4),'_events.mat'), ...
        'evts')
end

% Save the aggregated results

evts = newProcEvents;
save events_aggregated.mat evts
end