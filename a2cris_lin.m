%
% a2cris_lin -- airs2cris linearization test
%
% derives a linear transform from the airs2cris function and
% compares this with a direct airs2cris call, for translation
% of the 49 fitting profiles.  note that the linearization does 
% not work with the statistical correction.
%
% plots (1) a row of the linear transform for a selected CrIS
% channel, along with a nominal CrIS SRF and (2) several adjacent
% transform rows.
%
% see a2cris_srfs.m for a fancier SRF plot, including AIRS SRFs
%

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/utils
addpath /asl/packages/airs_decon/source

% AIRS SRFs
sfile = '/asl/matlab2012/srftest/srftables_m140f_withfake_mar08.hdf';

% AIRS 49 fitting profiles
load airs_fit_prof
afrq = vta;
ar_ref = rta;
ab_ref = rad2bt(afrq, ar_ref);
n = 2645;

% get airs2cris as a linear transform
opt1 = struct;
opt1.user_res = 'midres';  % target resolution
opt1.hapod = 1;  % Hamming apodization
opt1.scorr = 0;  % statistical correction
opt1.cfile = 'corr_midres.mat';  % correction weights
[Tac, cfrq] = airs2cris(eye(n), afrq, sfile, opt1);
Tac = real(Tac);

% air2cris translation of test data
[cr_ref1, cfrq] = airs2cris(ar_ref, afrq, sfile, opt1);

% apply airs-to-cris linear transform
cr_ref2 = Tac * ar_ref;

% convert to brightness temps, compare
cb_ref1 = real(rad2bt(cfrq, cr_ref1));
cb_ref2 = real(rad2bt(cfrq, cr_ref2));
% plot(cfrq, cb_ref1 - cb_ref2)

% select a CrIS channel
% v0 = 850;
  v0 = 1420;  
% v0 = 2350
[inst, user] = inst_params('MW', 773.1307, opt1);
ix = interp1(cfrq, 1:length(cfrq), v0, 'nearest');
v0 = cfrq(ix);

% calculate a nominal CrIS SRF
vs = 10;  % vgrid half-width
vgrid = v0 + 0 + (-vs : user.dv : vs);
ils = sinc(2*user.opd*(vgrid - v0))';
ils = hamm_app(ils);
[ils2, frq2] = finterp2(ils, vgrid, 20);
[jmax,jx] = max(ils);   % ILS peak
jfrq = vgrid(jx);       % frequency of ILS peak

% plot AIRS parent weights with CrIS SRF
figure(1)
vp = 5;   % plot half-width
y = Tac(ix, :);  % selected row of AIRS to CrIS transform
% plot(frq2, ils2, 'b', vgrid, ils, '+b', ...
%      afrq, y, 'g', afrq, y, 'og', v0, 0, '+r', 'linewidth', 2)
plot(frq2, ils2, 'b', afrq, y, 'og', jfrq, jmax, '+r', 'linewidth', 2)
axis([v0-vp, v0+vp, -0.1, 0.6]);
title('CrIS MW 0.6 cm sample ILS with AIRS parent weights')
legend('nominal CrIS ILS', 'AIRS channel weights', ...
       'CrIS channel center')
xlabel('wavenumber (cm-1)')
ylabel('weight') 
grid on; zoom on
% saveas(gcf, 'sample_ILS_with_AIRS_parents', 'png')

return

% plot a small span of AIRS transform parents
v0 = 850;
% v0 = 1400;
% v0 =  2350
ix = interp1(cfrq, 1:length(cfrq), v0, 'nearest');
ix = ix + (-2 : 2);

figure(2)
plot(afrq, Tac(ix, :), afrq, 0.1, '+k')
% plot(afrq, Tac(ix, :))
axis([v0-5,v0+5,-0.1,0.7]);
title('sample AIRS to CrIS transform rows')
xlabel('wavenumber (cm-1)')
ylabel('weight') 
grid on; zoom on

legend('2347.50 cm-1', '2348.75 cm-1', '2350.00 cm-1', ...
       '2351.25 cm-1', '2352.50 cm-1')


