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
% 1. Load spike data
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