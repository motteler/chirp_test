%
% make a bias correction file for AIRS-parent CHIRP
%
% bias should be AIRS-to-CrIS minus NPP CrIS.  Uses data from Chris
% H and embed the 1438 channel AIRS to CrIS bias in the 1679 channel
% CHIRP grid.  The bias version number is assigned here.
%

% frequency grid from cris2chirp
d1 = load('chirp_wnum');  
wnum_chirp = d1.wnum;
nchan_chirp = length(wnum_chirp);

% get Chris's bias data (on AIRS-to-CrIS grid)
%  bt_bias       1483x1                5932  single              
%  bt_mean       1483x1                5932  single              
%  bt_std        1483x1                5932  single              
%  freq             1x1483            11864  double              
%  rad_bias      1483x1                5932  single              

load /home/chepplew/data/sno/reports/airs_npp_cris_bias_vector_chirp_v1.mat
figure(1)
subplot(2,1,1)
plot(freq, bt_bias)
xlim([600,2600])
title('AIRS-to-CrIS minus NPP CrIS')
% xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on
subplot(2,1,2);
plot(freq, bt_std)
xlim([600,2600])
title('std dev of bias')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

% plot(freq(1:end-1), diff(bt_bias))
% axis([600,2600, -2, 2])
% grid on;

% embed in chirp grid
eix = interp1(wnum_chirp, 1:nchan_chirp, freq, 'nearest');
bias = zeros(nchan_chirp, 1);
bias(eix, 1) = rad_bias;

% name in bias file
wnum = wnum_chirp;

save bias_AQ_v01b  bias wnum

