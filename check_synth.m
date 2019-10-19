%
% some different tallies of synthetic and fixed channels
%
% struct d1 is from read_airs_h4
%

% from L1cNumSynth (2645x1)
num_fill  = sum(d1.L1cNumSynth == 12150);
num_fixed = sum(0 < d1.L1cNumSynth & d1.L1cNumSynth < 12150);
num_OK    = sum(d1.L1cNumSynth == 0);
num_fill + num_fixed
% num_fill + num_fixed + num_OK

% from NeN (2645x90x135)
bad_NeN = zeros(2654, 1);
for j = 1 : 2645
  tmp = d1.NeN(j,:,:);
  bad_NeN(j) = sum(tmp(:) == 999) > 0;
end
sum(bad_NeN)



