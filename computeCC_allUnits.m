function computeCC_allUnits(spikeFile, eventsFile, fLoc, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   DESCRIPTION
%
% Compute and save cross-correlograms for all spike-trains in a given data 
% set. The default time-range for lags used to compute the 
% cross-correlations is +/-XX.XXXX seconds, and the default binsize used
% for binning the spike data is 1e-3 seconds. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  POTENTIAL UPDATES
%
% 1. Allow for a variable range on the cross-correlation computation.
%
% 2. Allow for a variable binsize to be specified by the user.
%
% 3. Compute shuffled / bootstrapped estimates of second peak magnitude for
% automated detection of significant peaks in the cross-correlograms. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   WORKFLOW
%
% 1. Load spike data and events file
%
% 2. Pre-allocate storage for cross-correlations
%
% 3. Compute cross-correlations
%
% 4. Plot results (optional)
%
% 5. Save results (optional)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   INPUTS
%
% 1. Spike train data, <data>, in the format (nObs x 2), where nObs is the 
% total number of spikes recorded across all units (nUnits). The first 
% column of  <data> contains a list of timestamps corresponding to each 
% spike observed, and the second column of <data> specifies the unit that 
% each spike is attributed to.
%
% 2. <plotFlag> specifies whether or not to plot the results for the user
%
% 3. <saveFlag> specifies whether or not to save the results for the user,
% the default save location is the current working directory. If <varargin>
% is not empty, the results will be saved to the location specified by the
% user in varargin. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   OUTPUTS
%
% 1. <ccAllUnits>, an array containing all the cross-correlation data for
% each unit in the data set (nUnits x nUnits x nLags)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Load spike data and events file
if isempty(fLoc)
    spikeData = spikeFile;
    eventsData = eventsFile;
else
    s = load([fLoc filesep spikeFile]);
    sNames = fieldnames(s);
    eval(['spikeData = s.' sNames{1} ';'])
    s = load([fLoc filesep eventsFile]);
    sNames = fieldnames(s);
    eval(['eventsData = s.' sNames{1} ';'])
    clear s sNames
end

% 1a. Construct Binned Spike Trains
binSize = 1e-3;
nUnits = max(spikeData(:,2));
timeRange = 0:binSize:ceil(max(spikeData(:,1)));
data = zeros(nUnits,length(timeRange));
for uNum = 1:nUnits
    data(uNum,:) = histc(spikeData(spikeData(:,2) == uNum,1),timeRange);
end

% 1b. Check to see if any units have spikes falling within a 'refractory
% period' of 1ms
if any(max(data,[],2) > 1)
    uIDX = find(max(data,[],2) > 1);
    warning(['Unit(s) ' num2str(reshape(uIDX,1,[])) ...
        ' have spikes occuring within 1ms of each other'])
end

% 2. Pre-allocate storage for cross-correlations
maxLagTimes = .300; % +/- 300ms for cross-correlations
maxLags = maxLagTimes/binSize;
ccAllUnits = zeros(nUnits,nUnits,2*maxLags + 1);
if (maxLags - round(maxLags)) ~= 0
   error('computeCC_allUnits:argChk', ...
       ['binSize and maxLagTimes are not commensurate with one ' ...
       'another, please specify a commensurate pair.'])
end

% 3. Compute and store cross-correlation values (and auto-correlation
% values for sanity's sake)
for uNum_i = 1:nUnits-1
    for uNum_j = uNum_i:nUnits
        ccAllUnits(uNum_i,uNum_j,:) = xcorr(data(uNum_i,:),data(uNum_j,:),...
            maxLags,'unbiased');
    end
end

end