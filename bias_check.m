%
% compare applications of radiance and BT bias corrections
%

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/chirp_test

% get a sample airs-parent chirp granule
p1 = '/asl/isilon/chirp/chirp_AQ_test4/2019/063';
g1 = 'SNDR.SS1330.CHIRP.20190304T0059.m06.g010.L1_AQ.std.v02_20.U.2008161559.nc';
d1 = read_netcdf_h5(fullfile(p1, g1));

% index of valid AIRS-parent channels
eix = d1.chan_qc < 2;
wnum = d1.wnum(eix);

% choose a sample chirp spectra
rad1 = double(d1.rad(eix, 2000));
bt1 = rad2bt(wnum, rad1);

% get Chris's bias data
% new bias is AIRS-to-CrIS minus NPP CrIS
load /home/chepplew/data/sno/reports/airs_npp_cris_bias_vector_chirp_v1.mat
bt_bias = double(bt_bias);
rad_bias = double(rad_bias);

% subtract bt bias from sample chirp bt spectra
bt2 = bt1 - bt_bias;

% subtract rad bias from sample chirp rad spectra
rad2 = rad1 - rad_bias;
bt3 = rad2bt(wnum, rad2);

% view corrected values together
figure(1)
plot(wnum, bt2, wnum, bt3)
xlim([600,2600])
title('rad correction and BT correction')
legend('bt correction', 'rad correction')
grid on; zoom on

% plot the bt difference
figure(2)
plot(wnum, bt3 - bt2)
xlim([600, 2600])
title('rad correction minus BT correction')
grid on; zoom on

