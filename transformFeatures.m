function [X, unitKey] = transformFeatures( X, names )
%% function transformFeatures( X, names )
%
% Apply the feature transformation based on the feature name
%
% Created by the research group of Stephen Gliske (steve.gliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

nF = length(names);
assert( nF == size(X,2) );

unitKey = cell(1,nF);

for i=1:nF
  if( ~contains( names{i}, 'skew' ) )
    x = X(:,i);
    x(x<=0) = 0;
    X(:,i) = 10*log10(x);
    unitKey{i} = 'dB';
  else
    X(:,i) = atan( X(:,i));
  end
end