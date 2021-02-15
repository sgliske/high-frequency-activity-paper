function predictionAnalysis( paramKey )
%% function predictionAnalysis( paramKey )
%
% Script to conduct the prediction analysis
%
% Created by the research group of Stephen Gliske (steve.gliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% load HFOs for comparison
f = load('data-input/hfo-rates.mat');
hfoData = f.results;
rateName = 'rate_qHFO';

%% load data
A = dir(['data-results/*.' paramKey '.hfa-adjusted.mat']);
assert( ~isempty(A), 'No data files found');
nP = length(A);

ID      = cell(nP,1);
chanLevelFeature   = cell(nP,1);
chanIdx = cell(nP,1);
SOZ     = cell(nP,1);
RV      = cell(nP,1);
dbKey   = cell(nP,1);

full = cell(nP,1);

for i=1:nP
  dbKey{i} = A(i).name(1:9);
  assert( strcmp( hfoData(i).dbKey, dbKey{i} ) );
  
  %% load data
  f = load(['data-results/' dbKey{i} '.' paramKey '.hfa-adjusted.mat']);

  %% copy
  full{i}.SOZ = f.SOZ;
  full{i}.RV  = f.RV;
  full{i}.valid = f.validChan;
  full{i}.notHFAoutlier = ~f.outlierChannel;
  
  valid = f.validChan & ~f.outlierChannel;
  hfoData(i).notHFAoutlier = valid;
  hfoData(i).SOZ = f.SOZ(f.validChan);
  hfoData(i).RV  = f.RV(f.validChan);
  assert( all(f.validChan == isfinite(hfoData(i).(rateName)) ) );
  
  chanLevelFeature{i} = f.chanLevelFeature(valid,:);
  chanIdx{i} = find(valid);
  SOZ{i} = f.SOZ(valid);
  RV{i} = f.RV(valid);
  ID{i} = i*ones(size(SOZ{i}));
  
  %% check
  assert(all(isfinite(chanLevelFeature{i}(:))));
end

ID = cell2mat(ID);
chanLevelFeature = cell2mat(chanLevelFeature);
chanIdx = cell2mat(chanIdx);
SOZ = cell2mat(SOZ);
RV = cell2mat(RV);

%% prep storage
score = zeros(size(SOZ));
mdl = cell( nP, 1 );

%% loop over cross validation folds

for k=1:nP
  %% set up training and testing indices
  testIdx = ID == k;
  trainIdx = ~testIdx;
  
  %% compute weights
  nChanTot = length(ID);
  nChanTrain = sum(trainIdx);
  weight = zeros(nChanTot,1);
  for i=1:nP
    I = ID == i;
    weight(I) = nChanTrain/(nP-1)/sum(I);
  end
  weight(testIdx) = 0;

  %% shift and scale input data
  mu    = mean(chanLevelFeature(trainIdx,:));
  sigma = std(chanLevelFeature(trainIdx,:),1);
  chanLevelFeature = (chanLevelFeature - mu) ./ sigma;
  
  %% PCA
  [B,~,e] = pca( chanLevelFeature(trainIdx,:), 'centered','off' );
  nPCAdim = find( cumsum(e)/sum(e) > 0.95, 1 );
  fprintf('Fold %d, keeping %d features\n', k, nPCAdim );
  
  chanLevelFeaturePCA = chanLevelFeature * B(:,1:nPCAdim);  
  
  %% logistic regression
  mdl{i} = fitglm( chanLevelFeaturePCA(trainIdx,:), SOZ(trainIdx), 'distribution', 'binomial', 'link', 'logit', 'Weights', weight(trainIdx) );
  
  %% prediction
  score(testIdx) = predict( mdl{i}, chanLevelFeaturePCA(testIdx,:) );
  
  %% asymmetries
  asym.hfa_SOZ(k) = computeAsym( score(testIdx), SOZ(testIdx) );
  asym.hfa_RV(k)  = computeAsym( score(testIdx), RV(testIdx) );

  hfoRate = hfoData(k).(rateName);
  I = isfinite(hfoRate);
  hfoRate = hfoRate(I);
  valid   = hfoData(k).notHFAoutlier(I);
  assert( sum(valid) == sum(testIdx) );
  
  asym.hfo_SOZ(k) = computeAsym( hfoRate, hfoData(k).SOZ );
  asym.hfo_RV(k)  = computeAsym( hfoRate, hfoData(k).RV );

  asym.product_SOZ(k) = computeAsym( score(testIdx) .* hfoRate(valid), SOZ(testIdx) );
  asym.product_RV(k)  = computeAsym( score(testIdx) .* hfoRate(valid), RV(testIdx) );

  
end

%%

full = cell2mat(full);

%%

save(['data-results/prediction.' paramKey '.mat'], 'score', 'RV', 'SOZ', 'ID', 'chanIdx', 'asym', 'dbKey', 'full' );
