function plotRawData()
%% function plotRawData()
%
% Plot example raw data
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% prep

% load features before transformation and normalization
f = load('data-input/UMHS-0018.hfa.mat');

% select a few example channels
chans = [ 2 11 22 30 ];
nChan = length(chans);

% example epoch for later
epIdx = 525;

% selected features for this plot
fIdx = [1 2 8];
labels = {'Variance [dB]', 'atan(skewness)', 'mean LL [dB]'};

% colors
colors = [...
         0    0.4470    0.7410;...
    0.8500    0.3250    0.0980;...
    0.9290    0.6940    0.1250;...
    0.4940    0.1840    0.5560 ];

%% prep figure

fig = gcf;
fig.Position = [50 50 1200 800];
%fig.PaperUnits = 'inches';
%fig.PaperPosition = [0.25 0.25 6.5 fig.Position(4)/fig.Position(3)*6.5 ];
fig.Renderer = 'Painters';

%% gather features

X = zeros(nChan, 3, 2);
for j=1:nChan
  %% gather features
  I = f.epochIdx == epIdx & f.chanIdx == chans(j);
  
  X(j,:,1) = transformFeatures( f.featureMatrix(I,fIdx), f.featureNames(fIdx) );
  X(j,:,2) = transformFeatures( f.featureMatrix(I,fIdx+19), f.featureNames(fIdx+19) );
end

%% make axes
clf

xOffset = 0.08;
xWidth3 = (1-xOffset)/3;
xWidth4 = (1-xOffset)/4;
yOffset = 0.07;
yWidth = (1-yOffset)/4;

clear axRow
clear axFeat
for i=1:2
  for j=1:4
    axRaw( i, j  ) = axes( 'Position', [ xOffset+(j-1)*xWidth4 yOffset*(i==1)+(5-2*i)*yWidth xWidth4 yWidth] );  %#ok<SAGROW>
  end
  for j=1:3
    axFeat( i, j) = axes( 'OuterPosition', [ xOffset+(j-1)*xWidth3 yOffset*(i==1)+(4-2*i)*yWidth xWidth3 yWidth] );  %#ok<SAGROW>
  end
end


%% plot EEG traces

eegData = load('data-input/raw-data.mat');
fs = eegData.fs;

idx = (1:fs)-1 + 31*fs;

clear h
for j=1:4
   h(1) = plot(axRaw(1,j), -eegData.band_1(idx,j) );
   h(2) = plot(axRaw(2,j), -eegData.band_2(idx,j) );
   
   set( h, 'Color', colors(j,:) );
end

linkaxes(axRaw, 'xy');
set( axRaw, 'XLim', [-fs*0.05 range(idx)+fs*0.05] );
set( axRaw, 'YLim', [ -10 12] );

% Scale bars

xL = axRaw(1,1).XLim;

line( axRaw(1,1), 0.5*xL(1)*[1 1], [-2.5 2.5], 'LineWidth', 2.0, 'Color', 'k' );
text( axRaw(1,1), xL(1), 0, '5 \muV', 'HorizontalAlignment', 'right');

line( axRaw(1,1), [0.25 0.5]*fs, -6*[1 1], 'LineWidth', 2.0, 'Color', 'k' );
text( axRaw(1,1), 0.375*fs, -6, '0.25 sec', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top' );

%% feature value plots

for k=1:2
  for i=1:3
    for j=(i+1):3
      axes( axFeat(k,i+j-2) ); %#ok<LAXES>
      h = gscatter( X(:,i,k), X(:,j,k), (1:4)', colors, 'o', 10, 'off', labels{i}, labels{j} );
      for ii=1:length(h)
        h(ii).MarkerFaceColor = colors(ii,:);
      end
    end
  end
end

set(axFeat, 'Box', 'off', 'FontSize', 12);

hL = legend( axFeat(1,1), h, arrayfun(@(i) sprintf('Channel %d', i), chans, 'uniformoutput', false) );
hL.NumColumns = nChan;
hL.Position = [(1-xOffset-0.4)/2+xOffset 0.47 0.4 0.04];
hL.FontSize = 12;

%% letters for raw data plots

for i=1:size(axRaw,1)
  for j=1:size(axRaw,2)
  %%
  pos = [0 0 0.2 0.05];
  pos(1) = axRaw(i,j).Position(1);
  pos(2) = sum(axRaw(i,j).OuterPosition([2 4]));
  if( i==2)
    pos(2) = pos(2) - 0.09;
  end
  for k=1:2
    pos(k) = max( min( pos(k), 1-0.05), 0);
  end
  
  offset = (i-1)*7;
  
  h = annotation( 'textbox', pos );
  h.String = sprintf('%c) Chan. %d', char('A'+j-1+offset), chans(j) );
  h.FontSize = 18;
  h.FontWeight = 'bold';
  h.LineStyle = 'none';
  end
end

%% letters for feature plots
xShift = axRaw(1,1).OuterPosition(1) - axFeat(1,1).OuterPosition(1);

for i=1:size(axFeat,1)
  for j=1:size(axFeat,2)
  %%
  pos = [0 0 0.2 0.05];
  pos(1) = axFeat(i,j).Position(1) - 0.06;
  pos(2) = sum(axFeat(i,j).Position([2 4]));
  if( j==1 ) 
    pos(1) = pos(1) -  0.015;
  end
  for k=1:2
    pos(k) = max( min( pos(k), 1-0.05), 0);
  end
  
  offset = (i-1)*7+4;
  
  h = annotation( 'textbox', pos );
  h.String = sprintf('%c)', char('A'+j-1+offset) );
  h.FontSize = 18;
  h.FontWeight = 'bold';
  h.LineStyle = 'none';
  end
end

%% frequency band labels

pos = [0.125 3*yWidth + yOffset];
bands = {'Band 1 (30-80 Hz)', 'Band 2 (80-500 Hz)'};

for i=1:2
annotation( 'textarrow', pos(1)*[1 1], pos(2)*[1 1], 'HeadStyle','none','LineStyle', 'none', 'TextRotation', 90, ...
  'FontSize', 20, 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', ...
  'string', bands{i} );
  pos(2) = pos(2) - yWidth*2 - yOffset;
end

%% turn off axes

set( axRaw, 'Visible', 'off' );

%% save

print('plots/rawDataExample.svg', '-dsvg' );
print('plots/rawDataExample.tif', '-dtiff', '-r600' );


