function nStars = getNumStars( p )
%% function nStars = getNumStars( p )
%
% Number of stars (significance level) for a given p-value
%
% Created by the research group of Stephen Gliske (steve.gliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

nStars = nan(size(p));
for i=1:numel(p)
  if( p(i) < 0.0001 )
    nStars(i) = 4;
  elseif( p < 0.001 )
    nStars(i) = 3;
  elseif( p < 0.01 )
    nStars(i) = 2;
  elseif( p < 0.05 )
    nStars(i) = 1;
  else
    nStars(i) = 0;
  end
end
