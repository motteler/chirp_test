%
% basic 1-granule AIRS and CHIRP comparison
%

addpath /home/motteler/cris/ccast/source

ahome = '/asl/hpcnfs1/airs/L1C';  % AIRS source home
chome = '/asl/hpcnfs1/chirp/chirp_AQ_test'; % CHIRP output home

year = 2019;
dstr = '061';  % doy as a string
gi = 21;      % granule index

% paths to AIRS and CHIRP data (home/yyyy)
apath = fullfile(ahome, sprintf('%d', year), dstr);
cpath = fullfile(chome, sprintf('%d', year), dstr);

alist = dir(fullfile(apath, 'AIRS*L1C*.hdf'));
clist = dir(fullfile(cpath, 'SNDR.SS1330.CHIRP*.nc'));

agran = fullfile(apath, alist(gi).name);
cgran = fullfile(cpath, clist(gi).name);

d1 = read_airs_h4(agran);
d2 = read_netcdf_lls(cgran);

% AIRS indices
ix = 35;    % cross track (1-90)
ia = 60;   % along track (1-135)

% CHIRP index
ic = ix + (ia-1)*90;

v1 = d1.nominal_freq;
b1 = real(rad2bt(v1, d1.radiances(:,ix,ia)));

v2 = d2.wnum;
b2 = real(rad2bt(v2, d2.rad(:,ic)));

figure(1); clf
subplot(2,1,1)
plot(v1, b1, v2, b2)
axis([600, 2700, 200, 310])
title('AIRS and CHIRP comparison')
legend('AIRS', 'CHIRP', 'location', 'southeast')
grid on; zoom on

subplot(2,1,2)
plot(v1, b1, '+', v2, b2, 'o')
% axis([760,820,260,300])
% axis([1300,1360,220,300])
%  axis([640,700, 200,300])
  axis([1590,1610, 230,260])
title('AIRS and CHIRP detail')
legend('AIRS', 'CHIRP', 'location', 'southeast')
grid on; zoom on

