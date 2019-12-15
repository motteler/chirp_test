
% nedn is nchan x nobs

n999xobs = zeros(12150,1);
n999xchan = zeros(2645,1);

for i = 1 : 12150
  n999xobs(i) = sum(nedn(:,i) == 999);
end

for j = 1 : 2645
  n999xchan(j) = sum(nedn(j,:) == 999);
end

isequal(double(d1.L1cNumSynth), n999xchan)
% xx = double(d1.L1cNumSynth) - n999xchan;

figure(1)
plot(n999xobs)
title('NEdN 999 values by obs, all channels')
xlabel('obs index')
ylabel('999 values')

figure(2)
plot(wnum, n999xchan)
title('NEdN 999 values by chan, all obs')
xlabel('wavenumber')
ylabel('999 values')

return

figure(3)
% semilogy(wnum, d1.L1cNumSynth)
plot(wnum, d1.L1cNumSynth)
title('L1cNumSynth')
xlabel('wavenumber')
ylabel('count')

