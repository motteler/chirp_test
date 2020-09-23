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
%   bias  - bias (as BT)
%   
% OUTPUT
%   rad2  - rad1 with bias subtracted
%

function rad2 = bias_correct(wnum, rad1, bias)

% BT version
bt2 = real(rad2bt(wnum, double(rad1)) - bias);
rad2 = real(bt2rad(wnum, bt2));

% radiance version
% rad2 = rad1 - bias;

