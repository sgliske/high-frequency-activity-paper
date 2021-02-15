function plotScorePerChannel( dbKey, paramKey )
%% function plotScorePerChannel( dbKey, paramKey )
%
% Plot score per channel for given patient ('UMHS-00xx' or 'all') and
% parameter set
%
% Created by the research group of Stephen Gliske (steve.gliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% loop over all subjects?

if( strcmp(dbKey, 'all') )
   load(['data-results/prediction.' paramKey '.mat'], 'dbKey' );
   for i=1:length(dbKey)
     plotScorePerChannel(dbKey{i});
   end
   return
end

%% colors

% colors (from Okabe and Ito, plus two additional grays)
colors = [...
    0.00    0.45    0.70;...     % 6. blue
    0.80    0.40    0.00;...     % 7. vermillion
    0.95    0.90    0.25;...     % 5. yellow
    0.75    0.75    0.75;...     % light gray
    0.50    0.50    0.50;...     % dark gray
    0.00    0.00    0.00];       % 1. black

%% load hfa data and select subset for one subject

hfaData = load(['data-results/prediction.' paramKey '.mat']);

id = strcmp( dbKey, hfaData.dbKey );
if( ~any(id) )
  error('plotScorePerChannel:id_check_HFA', 'Invalid dbKey: "%s"', dbKey );
end
if( sum(id) ~= 1 )
  error('plotScorePerChannel:id_check_HFA', 'Corrupte file, multiple entries for dbKey "%s"', dbKey );
end

I = hfaData.ID == find(id);

chanIdx   = hfaData.chanIdx(I);
%SOZ       = hfaData.SOZ(I);
%RV        = hfaData.RV(I);
pHFAscore = hfaData.score(I);
SOZ       = hfaData.full(id).SOZ;
RV        = hfaData.full(id).RV;
valid_1   = hfaData.full(id).valid;
valid_2   = hfaData.full(id).notHFAoutlier;

%% load HFOs for comparison

hfoData = load('data-input/hfo-rates.mat');
hfoData = hfoData.results;
rateName = 'rate_qHFO';

id = strcmp( dbKey, {hfoData.dbKey} );
if( ~any(id) )
  error('plotScorePerChannel:id_check_HFO', 'Invalid dbKey: "%s"', dbKey );
end
if( sum(id) ~= 1 )
  error('plotScorePerChannel:id_check_HFO', 'Corrupte file, multiple entries for dbKey "%s"', dbKey );
end

hfoData = hfoData(id);

%% prep

fig = gcf;
fig.Position = [50 450 1200 200];

ROI = {'SOZ', 'RV'};
legendText = {'HFO Rate','pHFA Score','Product [a.u.]'};

%% plot

clf

nChan = max( max(chanIdx), length(hfoData.(rateName)) );
X1 = zeros(nChan,3);
X2 = zeros(nChan,3);
X1(:,1) = hfoData.(rateName);
X2(chanIdx,2) = pHFAscore; 
X1(:,3) = X1(:,1) .* X2(:,2);
X1(:,3) = X1(:,3) / max(X1(:,3))*max(X1(:,1));

h1 = bar( X1 );
hold on

%% add in SOZ/RV to left axis

nLines = 3;
heightFactor = 0.08;
yL_1 = ylim();
yL_1(1) = -nLines*heightFactor*yL_1(2);
ylim(yL_1);
%y3 = -2*g.YAxis(1).Limits(2)*heightFactor;
%g.YAxis(1).Limits(1) = y3;
%g.YAxis(2).Limits(1) = g.YAxis(2).Limits(2) / g.YAxis(1).Limits(2) * g.YAxis(1).Limits(1);

yyaxis left
y1 = 0;
y2 = yL_1(1)/nLines;

for i=find(SOZ)'
  hSOZ = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2], colors(4,:) );
  hSOZ.LineStyle = 'none';
end

for i=find(RV)'
  hRV = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2]+y2, colors(5,:) );
  hRV.LineStyle = 'none';
end

hRedacted = hRV; % dummy value for legend
for i=find( ~valid_1 )'
  hRedacted = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2]+2*y2, colors(6,:) );
  hRedacted.LineStyle = 'none';
end


%% right plot

yyaxis right
h2 = bar( X2 );

c1 = max(X1(:,1));
c2 = max(X2(:,2));

scaleFactor = c2/c1;

yL_2 = scaleFactor * yL_1;
ylim(yL_2);


%% fix cosmetics

for i=1:3
  h1(i).FaceColor = colors(i,:);
  h1(i).BarWidth = 1.5;
  h2(i).FaceColor = colors(i,:);
  h2(i).BarWidth = 1.5;
end

g = gca;

g.YAxis(1).Color = h1(1).FaceColor;
g.YAxis(2).Color = h1(2).FaceColor;

yyaxis left
ylabel( 'HFO rate [#/min]' );

yyaxis right
ylabel( {'pHFA score', '[odds]'} );

xlabel( 'Channel Number' );

g.FontSize = 14;
g.Box = 'off';

line(xlim(), [0 0], 'Color', 'k' );

xlim([0 nChan+1]);

% remove any ticks below zero
for i=1:2
  t = g.YAxis(i).TickValues;
  g.YAxis(i).TickValues = t(t>=0);
end

%% legend

hAll = [h1 hSOZ hRV hRedacted];
names = [legendText ROI 'Redacted'];
I = [true(size(legendText)), true(size(ROI)), ~all(valid_1), ~all(valid_2) ];

hL = legend( hAll(I), names(I) );
hL.Location = 'EastOutside';

%% save
print(['plots/' dbKey '.' paramKey '.pHFAscore.eps'], '-depsc');

