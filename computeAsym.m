function A = computeAsym( x, ROI )
%% function A = computeAsym( x, ROI )
%
% Function to compute the asymmetry of x relative to a given region of
% interest (ROI).  <x> and <ROI> expected to be vectors of the same size.
% <ROI> expected to be logical.
%
% Created by the research group of Stephen Gliske (sgliske@unmc.edu)
% Copyright (c) 2020
% Licensed under GPLv3
%

assert(all(x>0));

a = mean(x(ROI));
b = mean(x(~ROI));

A = (a-b)/(a+b);
