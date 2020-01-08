%
% NEdN interpolation demo
%
% show the effects of interpolation and apodization on NEdN
%

addpath /home/motteler/cris/ccast/source
addpath /home/motteler/shome/airs_decon/source
addpath /home/motteler/cris/ccast/motmsc/time
% s1 = '/asl/cris/ccast/sdr45_j01_HR/2018/091';
% s2 = 'CrIS_SDR_j01_s45_d20180401_t2148080_g219_v20a.mat';
s1 = '/home/motteler/shome/daac_test/SNPPCrISL1B.2/2019/062';
s2 = 'SNDR.SNPP.CRIS.20190303T2024.m06.g205.L1B.std.v02_05.G.190304043458.nc';
cris_gran = fullfile(s1, s2);

% interpolation options
opt1 = struct;
opt1.user_res = 'midres';    % target resolution
opt1.hapod = 1;              % 1 = hamming apodization
opt1.inst_res = 'hires3';    % nominal value for inst res
wlaser = 773.1301;           % nominal falue for wlaser

% read CrIS data
d1 = read_cris_h5(cris_gran);

% show measured NEdN for all 3 bands
figure(1)
semilogy(d1.wnum_lw, d1.nedn_lw, ...
         d1.wnum_mw, d1.nedn_mw, ...
         d1.wnum_sw, d1.nedn_sw)
axis([600, 2600, 0, 1])
title('CrIS high res granule mean NEdN')
xlabel('wavenumber')
ylabel('NEdN')
grid on; zoom on

% choose a band
% band = 'MW';
band = input('band > ', 's');
switch band
  case 'LW', wnum = d1.wnum_lw; nedn = mean(d1.nedn_lw, 2);
  case 'MW', wnum = d1.wnum_mw; nedn = mean(d1.nedn_mw, 2);
  case 'SW', wnum = d1.wnum_sw; nedn = mean(d1.nedn_sw, 2);
  otherwise, error('bad band spec');
end
nchan = length(wnum);

% get user band spec
[~, user] = inst_params(band, wlaser, opt1);

nrad = 100;    % simulated radiance obs per set
nset = 10;     % number of simulated radiance sets

% radiance at 280K
r_280K = bt2rad(wnum, 280) * ones(1, nrad);

% loop on radiance sets
for i = 1 : nset

  % add noise scaled to the NEdN spec
  r_nedn = r_280K + randn(nchan, nrad) .* (nedn * ones(1, nrad));

  % CrIS interpolation
  [rtmp, vtmp] = finterp(r_nedn, wnum, user.dv);
  rtmp = real(rtmp);

  if opt1.hapod
    rtmp = hamm_app(rtmp);
  end

  % initialize tables on the first iteration
  if i == 1
    tab_cris = zeros(length(wnum), nset);
    tab_intp = zeros(length(vtmp), nset);
  end

  % measure and save the simulated noise (as a check)
  tab_cris(:, i) = std(r_nedn, 0, 2);

  % measure and save the translated simulated noise
  tab_intp(:, i) = std(rtmp, 0, 2);

  fprintf(1, '.')
end
fprintf(1, '\n')

% take means over the std sets
nedn_cris = mean(tab_cris, 2);
nedn_intp = mean(tab_intp, 2);

figure(2)
semilogy(wnum, nedn, wnum, nedn_cris, vtmp, nedn_intp)
% axis([600, 2600, 0, 1])
title('CrIS NEdN estimates')
legend('granule mean', 'simulated', 'interpolated')
xlabel('wavenumber')
ylabel('NEdN')
grid on; zoom on

% scale factor for high res NEdN
k = mean(nedn_intp) / mean(nedn_cris);
fprintf(1, '%s %s hapod=%d, NEdN scale factor %.4f\n', ...
            band, opt1.user_res, opt1.hapod, k)

% semilogy(wnum, nedn, wnum, k*nedn_cris, vtmp, nedn_intp)

