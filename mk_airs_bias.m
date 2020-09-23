%
% make the bias correction file for airs-parent chirp
%
% bias should be airs-to-cris minus npp cris.  Uses data from Chris
% H and embed the 1438 channel airs-to-cris bias in the 1679 channel
% chirp grid.  The bias version number is assigned here.
%

% get Chris's bias data (on airs-to-cris grid)
load data/chirp_bias_vector_airs_npp_stats_sno_v01.mat

%    Name          Size          Bytes  Class
%   bt_bias       1483x1          5932  single              
%   bt_mean       1483x1          5932  single              
%   comments         1x9          2884  cell                
%   freq             1x1483      11864  double              
%   rad_bias      1483x1          5932  single              

figure(1); clf
% subplot(2,1,1)
plot(freq, bt_bias)
xlim([600,2600])
title('AIRS-to-CrIS minus NPP CrIS')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

% plot(freq(1:end-1), diff(bt_bias))

% frequency grid from cris2chirp
d1 = load('chirp_wnum');  
wnum_chirp = d1.wnum;
nchan_chirp = length(wnum_chirp);

% embed in chirp grid
eix = interp1(wnum_chirp, 1:nchan_chirp, freq, 'nearest');
bias = zeros(nchan_chirp, 1);
bias(eix, 1) = bt_bias;

% name in bias file
wnum = wnum_chirp;

save bias_airs_v01c comments bias wnum -v7.3

