
addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/chirp_test

% get a sample airs-parent chirp granule
p1 = '/asl/hpcnfs1/chirp/airs_L1c_src/2019/061';
g1 = 'SNDR.SS1330.CHIRP.20190302T0017.m06.g003.L1_AIR.std.v01_07.U.2004132229.nc';
d1 = read_netcdf_h5(fullfile(p1, g1));

% index of valid AIRS-parent channels
eix = d1.chan_qc < 2;
wnum = d1.wnum(eix);

% choose a sample chirp spectra
rad1 = double(d1.rad(eix, 1000));
bt1 = rad2bt(wnum, rad1);

% get Chris's bias data
% bias here should be NPP CrIS minus AIRS-to-CrIS
load /home/chepplew/data/sno/reports/airs_chirp_cris_bias_summary.mat

bt_bias = double(bt_bias);
rad_bias = double(rad_bias);

% add bt bias to sample chirp bt spectra
bt2 = bt1 + bt_bias;

% add rad bias to sample chirp rad spectra
rad2 = rad1 + rad_bias;
bt3 = rad2bt(wnum, rad2);

% plot the bt difference
plot(wnum, bt3 - bt2)
axis([600, 2600, -0.3, 0.3])
grid on; zoom on

