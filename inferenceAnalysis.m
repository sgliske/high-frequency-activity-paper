function inferenceAnalysis()
%% function inferenceAnalysis()
%
% Script to conduct the inference analysis
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% load HFOs for comparison

f = load('data-input\hfo_rates.mat');
hfoData = f.results;

%% load data
A = dir('data-results/*.hfa-adjusted.mat');
assert( ~isempty(A), 'No data files found');
nP = length(A);

ID       = cell(nP,1);
chanLevelFeature   = cell(nP,1);
SOZ      = cell(nP,1);
RV       = cell(nP,1);
hfo_rate = cell(nP,1);

wide_SOZ = cell(nP,1);
wide_RV  = cell(nP,1);
wide_hfo_rate = cell(nP,1);
wide_ID  = cell(nP,1);

%
for i=1:nP
  dbKey = A(i).name(1:9);
  assert( strcmp( hfoData(i).dbKey, dbKey ) );

  %% load data
  f = load(['data-results/' dbKey '.hfa-adjusted.mat']);

  %% copy for HFO analysis (less redacted channels)
  valid = f.validChan;
  wide_SOZ{i} = f.SOZ(valid);
  wide_RV{i} = f.RV(valid);
  wide_hfo_rate{i} = hfoData(i).rate(valid);

  wide_ID{i} = i*ones(size(wide_SOZ{i}));

  %% copy for HFA analysis (more redacted channels)
  valid = f.validChan & ~f.outlierChannel;
  chanLevelFeature{i} = f.chanLevelFeature(valid,:);
  SOZ{i} = f.SOZ(valid);
  RV{i} = f.RV(valid);
  ID{i} = i*ones(size(SOZ{i}));
  hfo_rate{i} = hfoData(i).rate(valid);
end

ID  = cell2mat(ID);
SOZ = cell2mat(SOZ);
RV  = cell2mat(RV);
hfo_rate = cell2mat(hfo_rate);
chanLevelFeature = cell2mat(chanLevelFeature);

wide_ID  = cell2mat(wide_ID);
wide_SOZ = cell2mat(wide_SOZ);
wide_RV  = cell2mat(wide_RV);
wide_hfo_rate = cell2mat(wide_hfo_rate);

%% compute weights

nChanTot = length(ID);
weight = zeros(nChanTot,1);
for i=1:nP
  I = ID == i;
  weight(I) = nChanTot/nP/sum(I);
end

wide_nChanTot = length(wide_ID);
wide_weight = zeros(wide_nChanTot,1);
for i=1:nP
  I = wide_ID == i;
  wide_weight(I) = wide_nChanTot/nP/sum(I);
end

%% 1D logistic regression

nF = size(chanLevelFeature,2);
soz_mdl = cell(nF+1,1);
rv_mdl  = cell(nF+1,1);
scaledMAD = zeros(nF+1,1);

for i=1:nF
  scaledMAD(i) = mad(chanLevelFeature(:,i),1) / norminv(0.75 );
  soz_mdl{i} = fitglm( chanLevelFeature(:,i) / scaledMAD(i), SOZ, 'distribution', 'binomial', 'link', 'logit', 'Weights', weight );
  rv_mdl{i}  = fitglm( chanLevelFeature(:,i) / scaledMAD(i), RV, 'distribution', 'binomial', 'link', 'logit', 'Weights', weight );
end

scaledMAD(end) = mad( wide_hfo_rate,1) / norminv(0.75 );
soz_mdl{end} = fitglm( wide_hfo_rate / scaledMAD(end), wide_SOZ, 'distribution', 'binomial', 'link', 'logit', 'Weights', wide_weight );
rv_mdl{end}  = fitglm( wide_hfo_rate / scaledMAD(end), wide_RV, 'distribution', 'binomial', 'link', 'logit', 'Weights', wide_weight );

%% correlation

chanLevelFeatureCorr = corr( [ chanLevelFeature hfo_rate ]);

%%

featureNames = f.featureNames;

save('data-results/inference.mat', 'soz_mdl', 'rv_mdl', 'chanLevelFeatureCorr', 'featureNames', 'scaledMAD' );
