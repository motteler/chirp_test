%
% a2cris_srfs -- airs2cris linearization with SRF plots
%
% derives a linear transform from the airs2cris function and plots
% a row of the transform for a selected CrIS channel, along with a
% nominal CrIS SRF and the associated AIRS SRFs
%

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/utils
addpath /asl/packages/airs_decon/source
addpath /asl/packages/airs_decon/data

% AIRS SRFs
sfile = 'airs_l1c_srf_tables_lls_20181205.hdf';

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
[Tac, cfrq] = airs2cris(eye(n), afrq, sfile, opt1);
Tac = real(Tac);

% save Tac for other applications
% save Tac afrq cfrq Tac

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

%----------------------------------------
% plot AIRS parent weights with CrIS SRF
%----------------------------------------
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

%--------------------------------------------------
% plot AIRS parent weights with AIRS and CrIS SRFs
%--------------------------------------------------
% get SRFs from mksconv
[sconv, sfreq, ofreq] = mksconv2(sfile, afrq, 0.05);

vp1 = 5;   % airs data subset half-width
aix = find(v0-vp1 <= afrq & afrq <= v0+vp1);

% take a subset of AIRS channels
afrq1 = afrq(aix);
y1 = y(aix);
sconv1 = sconv(aix,:);
sconv1 = sconv1';

% normalize
t2 = max(sconv1);
sconv1 = sconv1 ./ t2;

% scale SRFs by Tac row weights
t1 = sconv1 .* y1;

figure(2);
plot(jfrq, jmax, '+r', frq2, ils2, 'b', afrq, y, 'og', ...
     sfreq, t1, ':m', 'linewidth', 2);
axis([v0-vp, v0+vp, -0.1, 0.6]);
title('CrIS MW sample ILS with AIRS parent weights')
legend('CrIS channel center', 'CrIS 0.6 cm apodized ILS', ...
       'AIRS channel weights', 'AIRS weighted SRFs', ...
       'location', 'northwest')
xlabel('wavenumber (cm-1)')
ylabel('weight') 
grid on; zoom on
% saveas(gcf, 'sample_CrIS_ILS_with_AIRS_parent_SRFs', 'png')

