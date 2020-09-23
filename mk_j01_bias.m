%
% make a bias correction file for j1-parent chirp
%
% bias should be j1-to-npp minus npp cris.  For j1-parent we just
% copy the bias value.  The bias version number is assigned here.
%

% get Chris's bias data
load data/chirp_bias_vector_j01_npp_stats_v01.mat

%     Name          Size           Bytes  Class
%    bt_bias       1679x1           6716  single              
%    bt_mean       1679x1           6716  single              
%    comments         1x9           2904  cell                
%    freq          1679x1           6716  single              
%    rad_bias      1679x1           6716  single              

figure(1); clf
plot(freq, bt_bias)
xlim([600,2600])
title('J01-to-CrIS minus NPP CrIS')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

% plot(freq(1:end-1), diff(bt_bias))

% frequency grid from cris2chirp
d1 = load('chirp_wnum');  
wnum_chirp = d1.wnum;
nchan_chirp = length(wnum_chirp);

% names in bias file
wnum = wnum_chirp;
bias = bt_bias;

save bias_j01_v01a comments bias wnum -v7.3

