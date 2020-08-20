function plotPredictionResults()
%% function plotPredictionResults()
%
% Function to plot results of the prediction analysis
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% load data

f = load('data-results/prediction.mat');

%% prep

fig = gcf;
fig.Position = [100 100 1200 600];

ROI = {'SOZ', 'RV'};
legendText = {'HFO rate','pHFA score','Product'};

%% make plots/graphs and compute statistics
clf

clear ax;
for k=1:2
  %% bar plot
  if( k == 1 )
    X = [f.asym.hfo_SOZ; f.asym.hfa_SOZ; f.asym.product_SOZ]';
  else
    X = [f.asym.hfo_RV; f.asym.hfa_RV; f.asym.product_RV]';
  end
  
  ax(k) = axes('Position', [0.1 0.55-0.43*(k-1) 0.6 0.4] ); %#ok<*AGROW>
  hBar = bar(X);
  ax(k).Box = 'off';
    
  if( k==1 )
    hL = legend(legendText);
    hL.Position = [0.55 0.82 0.09 0.11];
    hL.Box = 'on';
  end
  
  set( hBar, 'LineWidth', 0.5 );
  
  %% box plot and statistics
  ax(k+2) = axes('Position', [0.75 0.55-0.43*(k-1) 0.24 0.4] ); %#ok<*AGROW>
  hold on

  hBox = boxplot(X);
  ax(k+2).Box = 'off';
  xlim([0.4 3.4]);
  
  set( hBox, 'LineWidth', 1, 'Color', 'k' );
  for i=1:3
    %% cosmetics with the boxplot
    
    % fill the box
    x = get( hBox(5,i), 'Xdata' );
    y = get( hBox(5,i), 'Ydata' );
    patch( x, y, -ones(size(x)), hBar(i).FaceColor );
    
    % set the median
    set( hBox(6,i), 'Color', 'k', 'LineWidth', 2 );
    
    % set the outliers
    set( hBox(7,i), 'Marker', 'd', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k' );
    
    %% p-values vs. zero
    
    % compute p-value
    p = signrank( X(:,i), 0, 'tail', 'right' );
    fprintf('%3s %7s vs %7s: p = %.4f (Sign Rank)\n', ROI{k}, legendText{i}, 'zero', p );
    
    % draw line
    x0 = i-0.3;
    xW = -0.05;
    y0 = median(X(:,i));
    line( [x0 x0+xW x0+xW x0], [0 0 1 1]*y0, 'color', 'k', 'LineWidth', 1 );
    
    fprintf('%3s %7s median: %.3f\n', ROI{k}, legendText{i}, y0 );
    
    % draw stars
    starSize = 40;
    nStars = getNumStars( p );
    scatter( cumsum(-ones(nStars,1)*0.08)+x0+xW, y0/2*ones(nStars,1), starSize, '*r' );
    
    %% p-values vs. others
    for j=(i+1):3
      % compute p-value
      tail = 'left';
      clear p
      p = signrank( X(:,i), X(:,j), 'tail', tail );
      fprintf('%3s %7s vs %7s: p = %.4f (Sign Rank)\n', ROI{k}, legendText{i}, legendText{j}, p );

      nStars = getNumStars( p );

      if( nStars )
        % draw line
        y0 = 0.8+(i+j-3)*0.2;
        yW = 0.03;
        line( [i i j j], y0 + [0 yW yW 0], 'Color', 'k', 'LineWidth', 1 ); 
        
        % draw stars
        x = cumsum(-ones(nStars,1)*0.06);
        x = x - mean(x);
        
        scatter( x+(i+j)/2, (y0+3*yW)*ones(nStars,1), starSize, '*r' );

      end
    end
  end
end

% last few cosmetic details

linkaxes(ax,'y');
ylim([-0.75 1.34]);

ax(1).XTickLabel = [];
ax(3).XTickLabel = [];
ax(2).XTickLabel = cellfun( @(x) x([1:2 5 8:9]), f.dbKey, 'UniformOutput', false);
ax(4).XTickLabel = legendText;

ylabel( ax(1), {ROI{1}, 'Asymmetry'} );
ylabel( ax(2), {ROI{2}, 'Asymmetry'} );

set( ax, 'fontsize', 14 )

% add letters for each panel

clear h
h(1) = annotation( 'textbox', [0.01 0.95 0.03 0.06] );
h(2) = annotation( 'textbox', [0.71 0.95 0.03 0.06] );
h(3) = annotation( 'textbox', [0.01 0.5 0.03 0.06] );
h(4) = annotation( 'textbox', [0.71 0.5 0.03 0.06] );

for i=1:4
  h(i).String = char('A'+i-1);
  h(i).FontSize = 18;
  h(i).FontWeight = 'bold';
  h(i).LineStyle = 'none';
end

%% save as eps and png files

print('plots/predictionResults.svg', '-dsvg');
print('plots/predictionResults.tif', '-dtiff', '-r600');


