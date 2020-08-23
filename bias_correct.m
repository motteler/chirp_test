%
% NAME
%   bias_correct - simple bias correction
%
% SYNOPSIS
%   rad2 = bias_correct(wnum, rad1, bias)
%
% INPUTS
%   wnum  - CHIRP frequency grid
%   rad1  - input radiances
%   bias  - bias (as radiance)
%   
% OUTPUT
%   rad2  - rad1 with bias added
%

function rad2 = bias_correct(wnum, rad1, bias)

rad2 = rad1 - bias;

% old BT correction
% bt2 = real(rad2bt(wnum, double(rad1)) + bias);
% rad2 = real(bt2rad(wnum, bt2));

