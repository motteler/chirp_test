%
% airs_num_synth - tabulate L1cNumSynth values
%

addpath /asl/packages/ccast/motmsc/time

% year and path to data
ayear = '/asl/data/airs/L1C/2017';

% days of the year
dlist = 183 : 203;

% tabulated values
ChanID_list = [];
ChanMapL1b_list = [];
L1cNumSynth_list = [];

% loop on days of the year
for di = dlist
  
  % loop on L1c granules
  doy = sprintf('%03d', di);
  flist = dir(fullfile(ayear, doy, 'AIRS*L1C*.hdf'));

  for fi = 1 : length(flist);

    afile = fullfile(ayear, doy, flist(fi).name);

%   lat = permute(hdfread(afile, 'Latitude'),  [2,1]);
%   lon = permute(hdfread(afile, 'Longitude'), [2,1]);
%   state = permute(hdfread(afile, 'state'),     [2,1]);

    ChanID = hdfread(afile, 'ChanID');
    ChanID = ChanID{1};
    ChanMapL1b = hdfread(afile, 'ChanMapL1b');
    ChanMapL1b = ChanMapL1b{1};
    L1cNumSynth = hdfread(afile, 'L1cNumSynth');
    L1cNumSynth = L1cNumSynth{1};

%   iOK = -90 <= tlat & tlat <= 90 & -180 <= tlon & tlon <= 180;
%   tlat = tlat(iOK); 
%   tlon = tlon(iOK);

    ChanID_list = [ChanID_list, ChanID'];
    ChanMapL1b_list = [ChanMapL1b_list, ChanMapL1b'];
    L1cNumSynth_list = [L1cNumSynth_list, L1cNumSynth'];

    if mod(fi, 10) == 0, fprintf(1, '.'), end
  end
  fprintf(1, '\n')
end

s2 = sum(L1cNumSynth_list');

figure(1)
semilogy(sort(s2), 'linewidth', 2)
axis([500, 2500, 1, 1e8])
title('synthetic obs for 5000 AIRS granules')
xlabel('sorted channels')
ylabel('number of synthetic values')
grid on

sum(s2 == 0)
sum(s2 == 1)
sum(s2 == 2)
sum(s2 > 6.05e7)

figure(2)
freq = hdfread(afile, 'nominal_freq'); freq = freq{1};
semilogy(freq, s2, '+')
axis([650, 2800, 0, 1e8])
title('synthetic obs for 5000 AIRS granules')
xlabel('channel frequency (cm-1)')
ylabel('number of synthetic values')
grid on

% spot check for changing arrays
% isequal(ChanID_list(:, 2), ChanID_list(:, 2002))
% isequal(ChanMapL1b_list(:, 2), ChanMapL1b_list(:, 2002))
% isequal(L1cNumSynth_list(:, 2), L1cNumSynth_list(:, 2002))

% basic count stats
nL1b = 2378;
nL1c = length(freq);
ndrop = sum(ChanMapL1b < 1)  % number of L1b channels not used in L1c
nmap = sum(ChanID <= 2378)  % number of L1c channels from L1b
nsyn = nL1c - nmap;
fprintf(1, '%d L1b chan mapped, %d synthesized\n', nmap, nsyn)

% compare with L1cNumSynth counts
imax = L1cNumSynth_list == 12150;
imin = L1cNumSynth_list == 0;    

xx = sum(imax') > 5000;


% jmax = cAND(imax');
% jmin = cAND(imin');

% i0 = 0 < L1cNumSynth_list;
% i1 = max(i0')';
% i2 = cOR(i0');
% s1 = sum(i0');

% figure(1)
% plot(sort(s1), 'linewidth', 2);
% axis([1000, 2400, 0, 5000])
% xlabel('number of channels')
% ylabel('number of granules')
% grid on

% figure(2)
% histogram(s1)

% L1cNumSynth_mean = mean(double(L1cNumSynth_list), 2);
% L1cNumSynth_std = std(double(L1cNumSynth_list), 0, 2);

% ix = 0 < L1cNumSynth_mean & L1cNumSynth_mean < 10000;
% L1cNumSynth_mean(ix);
% syn_std  = L1cNumSynth_std(ix);

