%
% define bias for AIRS-to-CHIRP
%
% bias should be NPP CrIS minus AIRS-to-CrIS.
%
% use initial values from Chris H and embed the 1438 channel AIRS to
% CrIS bias in the 1679 channel CHIRP grid
%
% bias version number is assigned here
%

% frequency grid from cris2chirp
d1 = load('chirp_wnum');  
wnum_chirp = d1.wnum;
nchan_chirp = length(wnum_chirp);

% get Chris's bias data (on AIRS-to-CrIS grid)
% bias here should be NPP CrIS minus AIRS-to-CrIS
%   bt_bias       1483x1              5932  single
%   bt_mean       1483x1             11864  double
%   freq          1483x1             11864  double
%   rad_bias      1483x1              5932  single

load data/airs_chirp_cris_bias_summary.mat

plot(freq, bt_bias)
axis([600,2600, -1, 1])
grid on;

% plot(freq(1:end-1), diff(bt_bias))
% axis([600,2600, -2, 2])
% grid on;

% embed in chirp grid
eix = interp1(wnum_chirp, 1:nchan_chirp, freq, 'nearest');
bias = zeros(nchan_chirp, 1);
bias(eix, 1) = bt_bias;

% name in bias file
wnum = wnum_chirp;

% save airs_bias_v01a  bias wnum


