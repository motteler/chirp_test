%
% run after a read leaving chirp data in struct d1
% 

figure(1)
plot(d1.wnum, d1.synth_frac, '+')
xlim([600, 2600])
title('chirp synthetic fraction')
xlabel('channel frequency (cm-1)')
ylabel('synthetic fraction')
grid on
saveas(gcf, 'chirp_sample_syn_frac', 'fig')

figure(2)
plot(sort(d1.synth_frac))            
title('sorted synthetic fraction', 'linewidth', 2)
xlabel('sorted index')
ylabel('synthetic fraction')
grid on
saveas(gcf, 'chirp_sorted_syn_frac', 'fig')

