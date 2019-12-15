%
% nedn_chirp -- noise estimate for the AIRS-to-CrIS translation
%

function nedn_tran = ...
  nedn_chirp(nedn_airs, freq_airs, nsynth_airs, Tac, sfile, opt1)

verbose = 0;

%----------------------------
% get AIRS granule mean NEdN
%----------------------------

[nchan_airs, nobs_airs] = size(nedn_airs);

fname = mfilename;  % this function name

% count the NEdN flagged values and compare with nsynth_airs
n999 = zeros(nchan_airs, 1);
for j = 1 : nchan_airs
  n999(j) = sum(nedn_airs(j,:) == 999);
end
if ~isequal(nsynth_airs, n999)
  fprintf(1, 'flagged NEdN count != nsynth_airs\n')
  % xx = nsynth_airs - n999;
  keyboard
end

% take the mean of valid NEdN values over the full granule
nOK = zeros(nchan_airs, 1);
sOK = zeros(nchan_airs, 1);
for j = 1 : nobs_airs
  iOK = nedn_airs(:, j) < 2;   % flag valid NEdN values
  nOK = nOK + iOK;
  sOK = sOK + iOK .* nedn_airs(:, j);
end
ntmp1 = sOK ./ nOK;

% interpolate the missing values
jOK = nOK > 0;  
ntmp2 = interp1(freq_airs(jOK), ntmp1(jOK), freq_airs, 'linear', 'extrap');

if verbose
  figure(2)
  semilogy(freq_airs(jOK), ntmp2(jOK), 'o', freq_airs(~jOK), ntmp2(~jOK), '+')
  axis([600, 2600, 0, 1])
  title('AIRS granule mean NEdN')
  legend('real channels', 'synthetic channels')
  xlabel('wavenumber')
  ylabel('NEdN')
  grid on; zoom on
end

%------------------------------
% measure translated CrIS NEdN 
%------------------------------

nrad = 100;    % simulated radiance obs per set
nset = 10;     % number of simulated radiance sets

% AIRS radiance at 280K
r_280K = bt2rad(freq_airs, 280) * ones(1, nrad);

% loop on radiance sets
for i = 1 : nset

  % add noise scaled to the AIRS NEdN spec
  r_airs = r_280K + randn(nchan_airs, nrad) .* (ntmp2 * ones(1, nrad));

  % AIRS to CrIS translation
  [r_tran, freq_tran] = airs2cris(r_airs, freq_airs, sfile, opt1);
  r_tran = real(r_tran);

  % initialize tables on the first iteration
  if i == 1
    tab_airs = zeros(length(freq_airs), nset);
    tab_tran = zeros(length(freq_tran), nset);
  end

  % measure and save the simulated noise (as a check)
  tab_airs(:, i) = std(r_airs, 0, 2);

  % measure and save the translated simulated noise
  tab_tran(:, i) = std(r_tran, 0, 2);

% fprintf(1, '.')
end
% fprintf(1, '\n')

% take means over the std sets
nedn_asim = mean(tab_airs, 2);
nedn_tran = mean(tab_tran, 2);

if verbose
  % plot the results
  figure(3); clf
  [x1, y1] = pen_lift(freq_airs, ntmp2);
  [x2, y2] = pen_lift(freq_airs, nedn_asim);
  [x3, y3] = pen_lift(freq_tran, nedn_tran);
  semilogy(x1, y1, x2, y2, x3, y3);
  axis([600, 2600, 0, 1])
  title('AIRS to CrIS NEdN estimates')
  legend('AIRS granule mean', 'AIRS simulated noise', ...
         'AIRS to CrIS translation')
  xlabel('wavenumber')
  ylabel('NEdN')
  grid on; zoom on
end % if verbose

