%
% basic 1-granule AIRS and CHIRP comparison
%

addpath /home/motteler/cris/ccast/source

ahome = '/asl/airs/l1c_v672';               % AIRS source home
chome = '/asl/isilon/chirp/chirp_AQ_test1'; % CHIRP output home

year = 2018;
dstr = '231';  % doy as a string
  gi = 24;       % granule index (no sw bias)
% gi = 13;       % granule index (prev significant SW bias)

% paths to AIRS and CHIRP data (home/yyyy)
apath = fullfile(ahome, sprintf('%d', year), dstr);
cpath = fullfile(chome, sprintf('%d', year), dstr);

alist = dir(fullfile(apath, 'AIRS*L1C*.hdf'));
clist = dir(fullfile(cpath, 'SNDR.SS1330.CHIRP*.nc'));

agran = fullfile(apath, alist(gi).name);
cgran = fullfile(cpath, clist(gi).name);

d1 = read_airs_h4(agran);
d2 = read_netcdf_h5(cgran);

v1 = d1.nominal_freq;
b1 = real(rad2bt(v1, d1.radiances(:,:)));
b1m = mean(b1,2);
[x1, y1] = pen_lift(v1, b1m);

v2 = d2.wnum;
b2 = real(rad2bt(v2, d2.rad(:,:)));
b2m = mean(b2,2);
[x2, y2] = pen_lift(v2, b2m);

figure(1); clf
plot(x1, y1, x2, y2)
xlim([650,1100])
title('AIRS and CHIRP LW')
legend('AIRS', 'CHIRP', 'location', 'south')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

figure(2); clf
plot(x1, y1, x2, y2)
xlim([1210,1610])
title('AIRS and CHIRP MW')
legend('AIRS', 'CHIRP', 'location', 'southwest')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

figure(3); clf
plot(x1, y1, x2, y2)
xlim([2180,2550])
title('AIRS and CHIRP SW')
legend('AIRS', 'CHIRP', 'location', 'southeast')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

return

figure(1); clf
subplot(2,1,1)
plot(x1, y1, '+r', x2, y2, 'og', x1, y1, 'r', x2, y2, 'g')
xlim([649,654])
title('AIRS and CHIRP LW band edges')
legend('AIRS', 'CHIRP', 'location', 'southwest')
ylabel('BT (K)')
grid on; zoom on

subplot(2,1,2)
plot(x1, y1, '+r', x2, y2, 'og', x1, y1, 'r', x2, y2, 'g')
xlim([1090,1097])
legend('AIRS', 'CHIRP', 'location', 'southwest')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

figure(2); clf
subplot(2,1,1)
plot(x1, y1, '+r', x2, y2, 'og', x1, y1, 'r', x2, y2, 'g')
xlim([1208, 1215])
title('AIRS and CHIRP MW band deges')
legend('AIRS', 'CHIRP', 'location', 'southwest')
ylabel('BT (K)')
grid on; zoom on

subplot(2,1,2)
plot(x1, y1, '+r', x2, y2, 'og', x1, y1, 'r', x2, y2, 'g')
xlim([1600, 1607])
legend('AIRS', 'CHIRP', 'location', 'southwest')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

figure(3); clf
subplot(2,1,1)
plot(x1, y1, '+r', x2, y2, 'og', x1, y1, 'r', x2, y2, 'g')
xlim([2180,2190])
title('AIRS and CHIRP SW band edges')
legend('AIRS', 'CHIRP', 'location', 'southwest')
ylabel('BT (K)')
grid on; zoom on

subplot(2,1,2)
plot(x1, y1, '+r', x2, y2, 'og', x1, y1, 'r', x2, y2, 'g')
  xlim([2545, 2552])
% xlim([2500, 2552])
legend('AIRS', 'CHIRP', 'location', 'southwest')
xlabel('wavenumber (cm-1)')
ylabel('BT (K)')
grid on; zoom on

