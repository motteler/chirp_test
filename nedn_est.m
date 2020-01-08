%
% NAME
%   nedn_est -- NEdN estimate for the AIRS-to-CrIS translation 
%
% SYNOPSIS
%   nedn_cris = nedn_est(nedn_airs, freq_airs, sfile, opt1)
%
% INPUTS
%   nedn_airs  - AIRS NEdN values
%   freq_airs  - AIRS frequency grid
%   sfile      - AIRS SRF tabulation file
%   opt1       - AIRS to CrIS translation options
%
% OUTPUT
%   nedn_cris  - AIRS to CrIS NEdN estimate
%
% DISCUSSION
%   from the NEdN estimate used in the AIRS decon paper
%
% AUTHOR
%  H. Motteler, 6 Dec 2019
%

function nedn_cris = ...
  nedn_est(nedn_airs, freq_airs, sfile, opt1)

verbose = 0;
if isfield(opt1, 'verbose'), verbose = opt1.verbose; end

fstr = mfilename;  % this function name

%----------------------------
% get AIRS granule mean NEdN
%----------------------------

[nchan_airs, nobs_airs] = size(nedn_airs);

% nedn_cris = NaN(nchan_airs, 1);  % initialize output
  nedn_cris = zeros(nchan_airs, 1);  % initialize output

% % count the NEdN flagged values and compare with nsynth_airs
% n999 = zeros(nchan_airs, 1);
% for j = 1 : nchan_airs
%   n999(j) = sum(nedn_airs(j,:) == 999);
% end
% if ~isequal(nsynth_airs, n999)
%   fprintf(1, 'flagged NEdN count != nsynth_airs\n')
%   keyboard
% end

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

if verbose 
  fprintf(1, '%s: %d / %d valid AIRS NEdN values\n', ...
    fstr, sum(jOK), nchan_airs);
end

if sum(jOK) < 2
  fprintf(1, '%s: too few valid AIRS NEdN values, continuing...\n', fstr)
  return
end

% interpolate the missing values
ntmp2 = interp1(freq_airs(jOK), ntmp1(jOK), freq_airs, 'linear', 'extrap');

if verbose == 2
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

end

% take means over the std sets
nedn_asim = mean(tab_airs, 2);
nedn_cris = mean(tab_tran, 2);

if verbose == 2
  % plot the results
  figure(3); clf
  [x1, y1] = pen_lift(freq_airs, ntmp2);
  [x2, y2] = pen_lift(freq_airs, nedn_asim);
  [x3, y3] = pen_lift(freq_tran, nedn_cris);
  semilogy(x1, y1, x2, y2, x3, y3);
  axis([600, 2600, 0, 1])
  title('AIRS to CrIS NEdN estimates')
  legend('AIRS granule mean', 'AIRS simulated noise', ...
         'AIRS to CrIS translation')
  xlabel('wavenumber')
  ylabel('NEdN')
  grid on; zoom on
end

