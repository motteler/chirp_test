%
% bias_corr_fix -- update the AIRS-to-CrIS bias correction
%
% The old value for the AIRS-to-CrIS minus NPP bias correction
% was off slightly because airs2cris used old SRF values for the
% "statistical correction".  The latter correction uses a separate
% linear function for each channel.  We can fix this by inverting
% the old functions, applying them to the AIRS-to-CrIS mean, and
% then applying the new forward corrections.
%
% sign review for the bias correction
%   bias = a2c - npp
%   a2c - bias = a2c - (a2c - npp) = npp
%
% a2c_old_bias = a2c_old_mean - npp_mean
% a2c_new_bias = a2c_new_mean - npp_mean;
%

addpath /home/motteler/shome/airs_decon/data
addpath /home/motteler/shome/chirp_test

%-----------------------------
% fix the old bias correction
%-----------------------------

% load Chris's bias data
%  bt_bias  -  AIRS to CrIS minus NPP
%  bt_mean  -  AIRS to CrIS mean BT
%  freq     -  associated frequency grid
p1 = '/home/chepplew/data/sno/reports';
f1 = 'airs_npp_cris_bias_vector_chirp_v1.mat';
d1 = load(fullfile(p1, f1));

a2c_old_mean = double(d1.bt_mean);
a2c_old_bias = double(d1.bt_bias);
npp_mean = a2c_old_mean - a2c_old_bias;

% load the old and new corrections
c1 = load('corr_midres_v1');
c2 = load('corr_midres_v2');

% combine correction bands
Pcor2old = [c1.Pcor2LW; c1.Pcor2MW; c1.Pcor2SW];
Pcor2new = [c2.Pcor2LW; c2.Pcor2MW; c2.Pcor2SW];
tcfrq = [c2.tcfrqLW; c2.tcfrqMW; c2.tcfrqSW];
if ~isclose(tcfrq, d1.freq)
  error('frequency grids don''t match')
end
nchan = length(tcfrq);

% loop on channels
a2c_new_mean = zeros(nchan,1);
for j = 1 : nchan

  % apply the inverse old correction
  y1 = a2c_old_mean(j,1);
  a1 = Pcor2old(j,1);
  b1 = Pcor2old(j,2);
  x1 = (y1 - b1) / a1;

  % apply the forward new correction
  a2 = Pcor2new(j,1);
  b2 = Pcor2new(j,2);
  y2 = a2 * x1 + b2;
  a2c_new_mean(j) = y2;
end

% get the new bias
a2c_new_bias = a2c_new_mean - npp_mean;

whos a2c_old_mean a2c_new_mean_ a2c_old_bias a2c_new_bias

% plot the bias and change
figure(1)
subplot(2,1,1)
plot(tcfrq, a2c_new_bias)
xlim([600,2600])
title('AIRS to CrIS new bias')
ylabel('dBT (K)')
grid on

subplot(2,1,2)
plot(tcfrq, a2c_new_bias - a2c_old_bias)
xlim([600,2600]); ylim([-0.09, 0.03])
title('AIRS to CrIS new minus old bias')
xlabel('wavenumber (cm-1)')
ylabel('dBT (K)')
grid on
% saveas(gcf, 'bias_corr_fix', 'fig')

% figure(2)
% plot(tcfrq, a2c_new_mean - a2c_old_mean)
% xlim([600,2600]); ylim([-0.09, 0.03])
% title('a2c new minus old means')
% grid on
% % saveas(gcf, 'a2c_new_minus_old_means', 'fig')

% bias and mean diffs should agree
if ~isequal(a2c_new_bias - a2c_old_bias, a2c_new_mean - a2c_old_mean)
  error('bias and mean diffs should be the same')
end

%-----------------------------------------------
% use a2c_new_bias as the chirp bias correction
%-----------------------------------------------

% get the frequency grid from cris2chirp
d2 = load('chirp_wnum');  
wnum_chirp = d2.wnum;
nchan_chirp = length(wnum_chirp);

% embed in chirp grid
eix = interp1(wnum_chirp, 1:nchan_chirp, tcfrq, 'nearest');
bias = zeros(nchan_chirp, 1);
bias(eix, 1) = a2c_new_bias;

% var name for the bias file
wnum = wnum_chirp;

comments = [
  "This is Chris H's AIRS - NPP bias data, from the file"
  "airs_npp_cris_bias_vector_chirp_v1, adjusted because"
  "the statistical correction used did not match the SRFs.
  "Source for the fix is chirp_test/bias_corr_fix.m"]; 

save bias_aq_v01d comments bias wnum -v7.3

% extra sanity check
d3 = load('bias_aq_v01c');
bias_v01c = zeros(nchan_chirp, 1);
bias_v01c(eix, 1) = a2c_old_bias;

isequaln(bias_v01c, d3.bias)

