%
% quick look at chirp granules
%

addpath /home/motteler/cris/ccast/source

p1 = '/asl/hpcnfs1/chirp/airs_L1c/2019/061';
g1 = 'CHIRP_AIRS-L1C_d20190302_t0047214_g008_v01b.nc';

p2 = '/asl/hpcnfs1/chirp/cris_npp/2019/061';
g2 = 'SNDR.CHIRP.SNPP.20190302T0159.m06.g021.L1C.std.v01c.U.2003041117.nc';

d1 = read_netcdf_lls(fullfile(p1, g1));
d2 = read_netcdf_lls(fullfile(p2, g2));

bt1 = real(rad2bt(d1.wnum, d1.rad));
bt2 = real(rad2bt(d2.wnum, d2.rad));

figure(1); clf
subplot(2,1,1)
plot(d1.wnum, bt1(:, 2001:2010))
title('AIRS to CHIRP sample BT spectra')
ylabel('BT (K)')
grid on

subplot(2,1,2)
plot(d2.wnum, bt2(:, 5001:5020))
title('CrIS NPP to CHIRP sample BT spectra')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on

return

figure(2); clf
subplot(2,1,1)
[x1, y1] = pen_lift(d1.wnum, d1.nedn);
semilogy(x1, y1)
ylim([0.001, 1.0])
title('AIRS to CHIRP NEdN')
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

% load a random AIRS and CrIS granules for an NEdN comparison
apath = '/asl/hpcnfs1/airs/L1C/2019/061';
agran = 'AIRS.2019.03.02.005.L1C.AIRS_Rad.v6.1.2.0.G19061124436.hdf';
d3 = read_airs_h4(fullfile(apath, agran));

cpath = '/home/motteler/shome/daac_test/SNPPCrISL1B.2/2019/061'
cgran = 'SNDR.SNPP.CRIS.20190302T0054.m06.g010.L1B.std.v02_05.G.190302083725.nc';
d4 = read_cris_h5(fullfile(cpath, cgran));

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
xlabel('wavenumber (cm-1)')
ylabel('mw sr-1 m-2')
grid on

subplot(2,1,2)
x1 = [d4.wnum_lw; d4.wnum_mw; d4.wnum_sw];
y1 = [d4.nedn_lw; d4.nedn_mw; d4.nedn_sw];
[x1, y1] = pen_lift(x1, y1);
semilogy(x1, y1)
ylim([0.001, 1.0])
title('CrIS NEdN')
ylabel('mw sr-1 m-2')
grid on

