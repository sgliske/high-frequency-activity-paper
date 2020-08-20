function data = adjustFeatures( dbKey )
%% function data = adjustFeatures( dbKey )
% 
% Auxillery function to adjust features based on the median value over all
% channels for a given epoch
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% check if requested to loop over all available data
if( nargin < 1 || strcmp(dbKey, 'all') )
  
  %% get list
  tic
  A = dir('data-input/*hfa.mat');
  nP = length(A);
  
  %% loop over subjects
  for i=1:nP
    dbKey = A(i).name(1:9);
    disp(dbKey);
    
    %% Run the function for this subject
    adjustFeatures( dbKey );
  end
  return
end

%% load data
f = load(['data-input/' dbKey '.hfa.mat']);

%% copy metadata
data.dbKey = dbKey;
data.SOZ = f.SOZ';
data.RV  = f.RV';
data.validChan = f.validChan';

%% prep storage
nF = size(f.featureMatrix,2);
nChan = max(f.chanIdx);
data.chanLevelFeature   = nan(nChan,nF);

%% loop over features
for j=1:nF
  %% transform
  x = transformFeatures( f.featureMatrix(:,j), f.featureNames(j) );
  
  %% reshape to be channel x time
  F = accumarray( [f.chanIdx, f.epochIdx], x );
  validChan = accumarray( f.chanIdx, 1 ) > 0;
  validEpoch = accumarray( f.epochIdx, 1 ) > 0;
  
  F( ~validChan, : ) = nan;
  F( :, ~validEpoch ) = nan;
  
  F = F - nanmedian(F);
  
  data.chanLevelFeature(:,j)   = quantile(F, 0.75, 2 );   % location of 75th quantile

  %% check for outlier channels
  if( j == 27 )
    data.iqr = iqr( F, 2 );
    data.outlierChannel = isoutlier( data.iqr, 'median' );
  end
end

%% save

data.featureNames = f.featureNames;
save(['data-results/' dbKey '.hfa-adjusted.mat'], '-struct', 'data');

