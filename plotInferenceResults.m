function plotInferenceResults()
%% function plotInferenceResults()
%
% Plot results of the inference analysis
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% load data

f = load('data-results/inference.mat');

%% fix feature names
names = [f.featureNames; 'HFO rate'];
nF = length(names);

for k=1:nF-1
  parts = strsplit( names{k}, '_' );
  names{k} = [parts{1} ' ' parts{2} ' (band ' parts{4} ')'];
end

%% Gather data

beta   = zeros(nF,2);
SE     = zeros(nF,2);
pValue = zeros(nF,2);
for i=1:nF
  for j=1:2
    if( j==1 )
      mdl = f.soz_mdl{i};
    else
      mdl = f.rv_mdl{i};
    end
    
    beta(i,j)   = mdl.Coefficients.Estimate(end);
    SE(i,j)     = mdl.Coefficients.SE(end);
    pValue(i,j) = mdl.Coefficients.pValue(end);
  end
end

%% prep

fig = gcf;
fig.Position = [100 100 1200 600];
%fig.PaperUnits = 'inches';
%fig.PaperPosition = [0.25 0.25 6.5 fig.Position(4)/fig.Position(3)*6.5 ];
clf

ROI = {'SOZ', 'RV'};

order = [ 4:4:19 1:4:19 2:4:19 3:4:19 ];
order = [ order order+19 39 ];

%% set up the canvas for the error bar plot

clf
ax = axes('Position', [0.15 0.1 0.37 0.85] );
hold on

xL = [0.77 2.8];
xlim(xL+[-0.002 0]);
ylim([-nF 0]);

for i=-nF+1:2:0
  hP = patch( [xL, flip(xL)], [0 0 1 1]+i, [1 1 1]*0.15, 'EdgeColor', 'w' );
  hP.FaceAlpha = 0.15;
end

g = gca;
g.XScale = 'log';
g.Box = 'off';

g.YTick = (-nF:0)+0.5;
g.YTickLabel = flip(names(order));

line( [1 1], ylim(), 'Color', 'k', 'LineWidth', 1 );

%

x = exp(beta);
y = repmat( -(1:nF)', 1, 2 )+0.5 + [1 -1]*0.25;
xL = x-exp(beta-1.96*SE);
xH = exp(beta+1.96*SE)-x;

hBar = errorbar( x(order,:), y(order,:), xL(order,:), xH(order,:), 'horizontal', 'o' );

for i=1:2
  hBar(i).MarkerFaceColor = hBar(i).Color;
  hBar(i).MarkerSize = 4;
  hBar(i).LineWidth = 2;
  hBar(i).CapSize = 0;
end

xlabel('Odds Ratio [sMAD]');

nStars = zeros(nF,2);
% add stars
for j=1:2
  stars.x = cell(nF,1);
  stars.y = cell(nF,1);
  
  for i=1:nF
    nStars(i,j) = getNumStars( pValue(i,j)*nF ); % multiply by nF for effective Bonferroni correction

    stars.x{i} = cumprod( ones(nStars(i,j),1)*1.04 )+1.55;
    stars.y{i} = y(i,j)*ones(nStars(i,j),1);
  end

  stars.x = cell2mat(stars.x(order));
  stars.y = cell2mat(stars.y(order));

  scatter( stars.x, stars.y, 20, 'r*' );
end

hL = legend(hBar, ROI);
hL.Position(1) = 0.42;

% correlation plot
ax(2) = axes('Position', [0.521 ax(1).Position(2) 0.47 ax(1).Position(4)] );
imagesc( f.chanLevelFeatureCorr(order,order) );
colorbar();
ax(2).YTickLabel = '';
ax(2).XTickLabel = '';

set( ax, 'fontsize', 14 );
ax(1).YAxis.FontSize = 12;

xlabel('Correlation Coefficient');

% add letters for each panel

h = annotation( 'textbox', [0.01 0.95 0.03 0.06] );
h.String = 'A';
h.FontSize = 18;
h.FontWeight = 'bold';
h.LineStyle = 'none';

h = annotation( 'textbox', [0.515 0.95 0.03 0.06] );
h.String = 'B';
h.FontSize = 18;
h.FontWeight = 'bold';
h.LineStyle = 'none';

% set the grid
ax(1).XGrid = 'on';

ax(1).GridColor = [1 1 1]*0.75;
ax(1).GridAlpha = 1;
ax(1).MinorGridColor = [1 1 1]*0.75;
ax(1).MinorGridAlpha = 1;

%%
fprintf('Number of features per significance level, SOZ\n');
tabulate(nStars(:,1));

fprintf('Number of features per significance level, RV\n');
tabulate(nStars(:,2));


%% save as eps and png files

print('plots/inferenceResults.svg', '-dsvg' );
print('plots/inferenceResults.tif', '-dtiff', '-r600' );

