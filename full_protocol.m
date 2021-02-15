function full_protocol( paramKey )
%% function full_protocol( paramKey )
%
% Main entry point of the code.  See README.md.  Note, the function logs
% output to "full_protocol.<paramKey>.log"
%
% <paramKey> is a key defining the parameter set, which defaults to the
% standard setting of 'width-300.mask-11.nBands'
%
% Created by the research group of Stephen Gliske (steve.gliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3


%% check input

if( nargin < 1 )
    paramKey = 'width-300.mask-11.nBands-2';
end

if( strcmp( paramKey, 'all' ) )
    %%
    ticZ = tic;
    A = dir('data-input/*.hfa.mat');
    allKeys = unique(arrayfun( @(x) x.name(11:end-8), A, 'uniformoutput', false ));
    for k=1:length(allKeys)
        fprintf('\n\n---------- %s ----------\n\n', allKeys{k});
        full_protocol( allKeys{k} );
    end
    toc(ticZ);
    return
end

%% log output

filename = ['full_protocol.' paramKey '.log'];

% empty the file
fclose(fopen(filename,'w+'));

% start logging
diary(filename);

%% normalize the features per time epoch, and compute 75th percentile
fprintf('Adjust features\n');
tic
adjustFeatures('all',paramKey);
toc

%% examples plots 
plotRawData( paramKey );  % Fig. 1
plotFeatureExample( paramKey ); % Fig. 2

%% conduct the inference analysis and plot the results
fprintf('\n\nInference Analysis\n');
tic
inferenceAnalysis(paramKey);
toc

%%
plotInferenceResults(paramKey); % Fig. 3

%% conduct the prediction analysis and plot the results
fprintf('\n\nPrediction Analysis\n');
tic
predictionAnalysis(paramKey);
toc

%%
plotScorePerChannel( 'UMHS-0035', paramKey ); % Fig. 4
plotPredictionResults(paramKey); % Fig. 5

%% end log
diary off