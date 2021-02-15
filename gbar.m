function [ harray, h ] = gbar( x, label, n, colors, doNormalize, x_range )
%% function [ harray, h ] = gbar( x, label, n, colors, doNormalize, x_range )
%
% Function to make bar plot for multiple groups
%
% Created by the research group of Stephen Gliske (steve.gliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

if( nargin < 5 )
    doNormalize = 0;
end
if( nargin < 6 )
  x_range = [min(x), max(x)];
end

label = label - min(label) + 1;

x1 = x_range(1);
x2 = x_range(2);

edges = linspace( x1, x2, n+1 );
nlabels = max(label);
if( length(colors) ~= nlabels && ~isempty(colors) )
    err = MException('gbar:inputMismatch', 'Number of colors does not match number of labels');
    throw(err);
end

h = zeros(length(edges),nlabels);

for i=1:nlabels
   h(:,i) = histc( x(label==i), edges );
   
   if( doNormalize )
       h(:,i) = h(:,i) / sum(h(:,i));
   end
end

harray = bar( edges, h, 'histc' );

if( ~isempty(colors) )
    for i=1:nlabels
        if( isa(colors,'cell') )
            set( harray(i), 'FaceColor', colors{i} );
            set( harray(i), 'EdgeColor', colors{i} );
        else
            set( harray(i), 'FaceColor', colors(i) );
            set( harray(i), 'EdgeColor', colors(i) );
        end
    end
end

if nargout < 1
harray = [];
h = [];
end

end

