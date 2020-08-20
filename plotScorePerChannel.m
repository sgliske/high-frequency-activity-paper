function plotScorePerChannel( dbKey )
%% function plotScorePerChannel( dbKey )
%
% Plot score per channel for given patient ('UMHS-00xx' or 'all')
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

%% loop over all subjects?

if( strcmp(dbKey, 'all') )
   load('data-results/prediction.mat', 'dbKey' );
   for i=1:length(dbKey)
     plotScorePerChannel(dbKey{i});
   end
   return
end

%% load hfa data and select subset for one subject

hfaData = load('data-results/prediction.mat');

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

hfoData = load('data-input/hfo_rates.mat');
hfoData = hfoData.results;

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
legendText = {'HFO rate','pHFA Score','Normalized Product'};

%% plot

clf

nChan = max( max(chanIdx), length(hfoData.rate) );
X1 = zeros(nChan,3);
X2 = zeros(nChan,3);
X1(:,1) = hfoData.rate;
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
  hSOZ = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2], [1 1 1]*0.75 );
  hSOZ.LineStyle = 'none';
end

for i=find(RV)'
  hRV = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2]+y2, [1 1 1]*0.5 );
  hRV.LineStyle = 'none';
end
hV1 = hRV; % dummy value
for i=find( ~valid_1 )'
  hV1 = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2]+2*y2, [0 1 0]*0.66 );
  hV1.LineStyle = 'none';
end

hV2 = hRV; % dummy value
for i=find( ~valid_2 )'
  hV2 = patch( [i i i+1 i+1]-0.5, [y2 y1 y1 y2]+2*y2, [0 1 0]*0.33 );
  hV2.LineStyle = 'none';
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

h2(2).FaceColor = h1(2).FaceColor;
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

%% legend

hAll = [h1 hSOZ hRV hV1 hV2];
names = [legendText ROI 'Redacted (preprocessing)' 'Redacted (HFA outlier)'];
I = [true(size(legendText)), true(size(ROI)), ~all(valid_1), ~all(valid_2) ];

hL = legend( hAll(I), names(I) );
hL.Location = 'EastOutside';
%hL.Position(1) = hL.Position(1) + 0.01;

%% save
print(['plots/' dbKey '.pHFAscore.svg'], '-dsvg');
print(['plots/' dbKey '.pHFAscore.tif'], '-dtiff', '-r600');

