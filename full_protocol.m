%% full_protocol
%
% Main entry point of the scripts.  See README.md.  Note, the script logs
% output to "full_protocol.log"
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3

%% log output

filename = 'full_protocol.log';

% empty the file
fclose(fopen(filename,'w+'));

% start logging
diary(filename);

%% normalize the features per time epoch, and compute 75th percentile
fprintf('Adjust features\n');
tic
adjustFeatures('all');
toc

%% examples plots
plotRawData();  % Fig. 1
plotFeatureExample(); % Fig. 2

%% conduct the inference analysis and plot the results
fprintf('\n\nInference Analysis\n');
tic
inferenceAnalysis();
toc

plotInferenceResults(); % Fig. 3

%% conduct the prediction analysis and plot the results
fprintf('\n\nPrediction Analysis\n');
tic
predictionAnalysis();
toc

plotScorePerChannel('all'); % Fig. 4
plotPredictionResults(); % Fig. 5

%% end log
diary off