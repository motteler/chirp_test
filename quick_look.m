%
% quick look at chirp granules
%
% the AIRS and CrIS granules don't have to match, but AIRS 
% should match with AIRS-parent CHIRP, and similarly for CrIS, 
% for comparing NEdN
%

addpath /home/motteler/cris/ccast/source

p1 = '/asl/isilon/chirp/chirp_AQ_test3/2018/231';
g1 = 'SNDR.SS1330.CHIRP.20180819T0229.m06.g025.L1_AQ.std.v02_20.U.201029143145.nc';

p2 = '/asl/isilon/chirp/chirp_SN_test1/2018/231';
g2 = 'SNDR.SS1330.CHIRP.20180819T0159.m06.g021.L1_SN.std.v02_20.U.2009171805.nc';

[d1, a1] = read_netcdf_h5(fullfile(p1, g1));  % AIRS parent 
[d2, a2] = read_netcdf_h5(fullfile(p2, g2));  % CrIS parent

bt1 = real(rad2bt(d1.wnum, d1.rad));
bt2 = real(rad2bt(d2.wnum, d2.rad));

figure(1); clf
subplot(2,1,1)
plot(d1.wnum, bt1(:, 2001:2020))
title('AIRS to CHIRP sample BT spectra')
ylabel('BT (K)')
grid on

subplot(2,1,2)
plot(d2.wnum, bt2(:, 2001:2020))
title('CrIS NPP to CHIRP sample BT spectra')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on

figure(2); clf
subplot(2,1,1)
[x1, y1] = pen_lift(d1.wnum, d1.nedn);
semilogy(x1, y1)
ylim([0.001, 1.0])
title('AIRS L1C to CHIRP NEdN')
ylabel('mw sr-1 m-2')
grid on

subplot(2,1,2)
[x2, y2] = pen_lift(d2.wnum, d2.nedn);
semilogy(x2, y2)
ylim([0.001, 1.0])
title('CrIS NPP to CHIRP NEdN')
xlabel('wavenumber (cm-1)')
ylabel('mw sr-1 m-2')
grid on

return

% load corresponding AIRS and CrIS granules for an NEdN comparison
apath = '/asl/airs/l1c_v672/2018/231';
agran = 'AIRS.2018.08.19.025.L1C.AIRS_Rad.v6.7.2.0.G20008184914.hdf';
d3 = read_airs_h4(fullfile(apath, agran));

cpath = '/asl/cris/nasa_l1b/npp/2018/231';
cgran = 'SNDR.SNPP.CRIS.20180819T0200.m06.g021.L1B.std.v02_05.G.180819153434.nc';
d4 = read_netcdf_h5(fullfile(cpath, cgran));

% AIRS L1c NEdN
nchan_airs = 2645;
nobs_airs = 90 * 135;
nedn_airs = d3.NeN;

% take the mean of valid NEdN values over the full granule
nOK = zeros(nchan_airs, 1);
sOK = zeros(nchan_airs, 1);
for j = 1 : nobs_airs
  iOK = nedn_airs(:, j) < 2;  % flag per-obs valid NEdN values
  nOK = nOK + iOK;
  sOK = sOK + iOK .* nedn_airs(:, j);
end
jOK = nOK > 0;         % flag valid AIRS NEdN values
ntmp1 = sOK ./ nOK;    % mean of all AIRS NEdN values

figure(3); clf
subplot(2,1,1)
x1 = d3.nominal_freq;
y1 = ntmp1;
[x1, y1] = pen_lift(x1, y1);
semilogy(x1, y1)
ylim([0.001, 1.0])
title('AIRS L1c NEdN')
ylabel('mw sr-1 m-2')
grid on

subplot(2,1,2)
x1 = [d4.wnum_lw; d4.wnum_mw; d4.wnum_sw];
y1 = [d4.nedn_lw; d4.nedn_mw; d4.nedn_sw];
[x1, y1] = pen_lift(x1, y1);
semilogy(x1, y1)
ylim([0.001, 1.0])
title('CrIS NEdN')
xlabel('wavenumber (cm-1)')
ylabel('mw sr-1 m-2')
grid on

