%
% basic CrIS/CHIRP sinc ILS plot
%

addpath /asl/packages/ccast/source
addpath /asl/packages/ccast/motmsc/utils
addpath /asl/packages/airs_decon/source

% specify CrIS band and channel
% band = 'LW';  v0 = 850;
  band = 'MW';  v0 = 1420;  
% band = 'SW';  v0 = 2350

opt1 = struct;
opt1.user_res = 'midres';   % target resolution
[inst, user] = inst_params(band, 773.1307, opt1);

% get v0 index on the CrIS user grid
cfrq = cris_ugrid(user);
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

% plot the SRF
figure(1)
vp = 5;   % plot half-width
plot(frq2, ils2)
axis([v0-vp, v0+vp, -0.1, 0.6]);
title(sprintf('CrIS %s %s apodized sample ILS', band, opt1.user_res))
xlabel('wavenumber (cm-1)')
ylabel('weight') 
grid on; zoom on

