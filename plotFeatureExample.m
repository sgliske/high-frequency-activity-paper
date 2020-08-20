function plotFeatureExample()
%% function plotFeatureExample()
%
% Plot example feature plot
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%


%% load features before transformation and normalization
f = load('data-input/UMHS-0018.hfa.mat');

% select a few example channels
chans = [ 2 11 22 30 ];
nChan = length(chans);

% example epoch for later
epIdx = 525;

% select the feature
featIdx = 27;

%% transform all features

[x,unitKey] = transformFeatures( f.featureMatrix(:,featIdx), f.featureNames(featIdx) );
if( isempty( unitKey ) )
  unitKey = '[a.u.]';
else
  unitKey = ['[' unitKey{1} ']'];
end

%% feature name

parts = strsplit( f.featureNames{featIdx}, '_' );
featName1 = [parts{2} ' ' parts{1} ' ' unitKey];
featName2 = ['(band ' parts{4} ')'];


%% reshape to be channel x time
F1 = accumarray( [f.chanIdx, f.epochIdx], x );

validChan = accumarray( f.chanIdx, 1 ) > 0;
validEpoch = accumarray( f.epochIdx, 1 ) > 0;

%% subtract offset

F2 = F1;

F2( ~validChan, : ) = nan;
F2( :, ~validEpoch ) = nan;

mu = nanmedian(F2);
F2 = F2 - mu;

%% prep

fig = gcf;
fig.Position = [100 100 1200 300];
fig.Renderer = 'Painters';
 
%% plot

clf

clear ax
axWidth = 0.295;
offset = -0.016;
axYmax = 0.99;
axYmin = 0.00;
axYheight = axYmax - axYmin;
ax(1) = axes( 'OuterPosition', [ 0         axYmin axWidth axYheight ]);
ax(2) = axes( 'OuterPosition', [ axWidth   axYmin axWidth axYheight ]);
ax(3) = axes( 'OuterPosition', [ 1-axWidth axYmin axWidth axYheight ]);
ax(4) = axes( 'OuterPosition', [ 2*axWidth+offset axYmin+0.2 0.1 0.1 ]);
ax(4).Visible = 'off';

% plot before adjusting by median

axes(ax(1));
plot(find(validEpoch), F1(chans,validEpoch)','.')

% plot after adjusting

axes(ax(2));
hLine = plot(find(validEpoch), F2(chans,validEpoch)','.');

% extra plot for the legend
axes(ax(4));

hForLegend = gscatter(Inf*ones(1,nChan), Inf*ones(1,nChan), 1:nChan, [], [], [], 'off' );
for i=1:nChan
  hForLegend(i).MarkerSize = 30;
  hForLegend(i).MarkerFaceColor = hLine(i).Color;
  hForLegend(i).MarkerEdgeColor = hLine(i).Color;

  %hForLegend(i|nChans).MarkerSize = hForLegend30;
  %hForLegend(i+nChans).MarkerFaceColor = 'w';
  %hForLegend(i+nChans).MarkerEdgeColor = hForLegend(i).MarkerEdgeColor;
end

ax(4).Visible = 'off';

% box plot

axes(ax(3));
hBox = boxplot(F2(chans,:)');
linkaxes( ax([1 2 3]), 'y' );

%set( hBox, 'LineWidth', 1, 'Color', 'k' );
set( hBox, 'Color', 'k' );
for i=1:nChan
  set( hBox(:,i), 'Color', hLine(i).Color, 'LineStyle', '-'   )
end

for i=1:size(hBox,2)
  % cosmetics with the boxplot
  
  % fill the box
  x = get( hBox(5,i), 'Xdata' );
  y = get( hBox(5,i), 'Ydata' );
  patch( x, y, -ones(size(x)), hLine(i).Color );
  
  % set the median
  set( hBox(6,i), 'Color', 'k', 'LineWidth', 2 );
  
  % set the outliers
  set( hBox(7,i), 'Marker', 'd', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'MarkerSize', 2 );
end

%% cosmetics

% adjust limits of first two plots

yL = zeros(2,2);
for i=1:2
  yL(:,i) = ylim(ax(i));
end

[~,i] = max(range(yL));
j = 3-i;

ylim(ax(j), yL(:,i)-mean(yL(:,i)) + mean(yL(:,j)));

maxEpochs = find(validEpoch,1,'last');
xlim(ax(1:2),[0 maxEpochs+1]);

% labels
axes(ax(1));
xlabel('Epoch Number');
ylabel({'Nominal',featName1,featName2});

axes(ax(2));
xlabel('Epoch Number');
ylabel({'Adjusted',featName1,featName2});

axes(ax(3));
xlabel('Channel');
ylabel({'Adjusted',featName1,featName2});
ax(3).XTick = 1:nChan;
ax(3).XTickLabel = chans;

set( ax, 'Box', 'off' );
set( ax, 'fontsize', 14 );

%% Indicate where EEG samples are from

axes(ax(1))
hP = patch( epIdx + [-1 -1 1 1]*1.5, [ylim, flip(ylim)], [1 1 1]*0.5 );
hP.EdgeColor = hP.FaceColor;
hP.EdgeAlpha = 0.5;
hP.FaceAlpha = 0.5;

hP2 = copyobj( hP, ax(2) );
hP2.YData = [ax(2).YLim, flip(ax(2).YLim) ];


%% legend
axes(ax(4));

legendText_1 = arrayfun(@(i) sprintf('Channel %d', i), chans, 'uniformoutput', false);
legendText_2 = 'Fig. 1 Epoch'; %sprintf('Epoch %d', epIdx);

hL = legend( [hForLegend; hP], [legendText_1, legendText_2] );
set( hL, 'fontsize', 12 );
hL.Position(1) = 2*axWidth+offset*1.0;
hL.Position(2) = ax(2).Position(2)+0.5*ax(2).Position(4) - 0.5*hL.Position(4);

%% letters

allAx = ax(1:3);

for i=1:length(allAx)
  if( i==1 )
    xOffset = 0;
  else
    xOffset = 0.01;
  end
  yOffset = -0.04;
  
  pos = [0 0 0.03 0.06];
  pos(1) = allAx(i).OuterPosition(1)+xOffset;
  pos(2) = sum(allAx(i).OuterPosition([2 4]))+yOffset;
  for j=1:2
    pos(j) = max( min( pos(j), 1), 0);
  end
  
  h = annotation( 'textbox', pos );
  h.String = char('A'+i-1);
  h.FontSize = 18;
  h.FontWeight = 'bold';
  h.LineStyle = 'none';
end

%% save

print(sprintf('plots/featureExample.featIdx-%02d.svg', featIdx), '-dsvg' );
print(sprintf('plots/featureExample.featIdx-%02d.tif', featIdx), '-dtiff', '-r600' );


