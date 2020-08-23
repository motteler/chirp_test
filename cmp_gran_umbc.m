%
% compare last 2 runs of the same granule
%

addpath /home/motteler/cris/ccast/source

% airs-parent chirp
p1 = '/asl/isilon/chirp/chirp_AQ_test4/2019/058';
t1 = 'SNDR.SS1330.CHIRP.20190227T1353.m06.g139.L1_AQ.std.v02_20.U.*.nc';

% J1 cris-parent chirp
% p1 = '/asl/isilon/chirp/chirp_J1_test4/2019/058';
% g1 = 'SNDR.SS1000.CHIRP.20190227T0859.m06.g091.L1_J1.std.v02_20.U.*.nc';

% SN cris-parent chirp
% p1 = '/asl/isilon/chirp/chirp_SN_test4/2019/058';
% g1 = 'SNDR.SS1330.CHIRP.20190227T0859.m06.g091.L1_SN.std.v02_20.U.*.nc';

% grab the last two files in the list
flist = dir(fullfile(p1, t1));
g1 = flist(end-1).name;
g2 = flist(end).name;

[d1, a1] = read_netcdf_h5(fullfile(p1, g1));
[d2, a2] = read_netcdf_h5(fullfile(p1, g2));

if isequaln(d1, d2) 
  fprintf(1, 'data structs are identical\n')
else
  fprintf(1, 'checking individual data fields\n')
  dn1 = fieldnames(d1);
  dn2 = fieldnames(d2);
   
  % sort the field names
  [ds1, jx1] = sort(dn1);
  [ds2, jx2] = sort(dn2);

  if isequal(ds1, ds2)
    fprintf(1, 'data field names are identical\n')
  else
    fprintf(1, 'checking individual data field names\n')
    for j = 1 : length(dn1)
      if ~isequal(dn1{jx1(j)}, dn2{jx2(j)})
        fprintf(1, 'data names differ, index %d\n', j)
        dn1{jx1(j)}
        dn2{jx2(j)}
        continue
      end
    end
  end

  fprintf(1, 'checking individual data values\n')
  for j = 1 : length(dn1)
    if ~isequaln(d1.(dn1{jx1(j)}), d2.(dn2{jx2(j)}))
      fprintf(1, 'data values differ, index %d\n', j)
      display([dn1{jx1(j)}, '  ', dn2{jx2(j)}])
    end
  end
end

if isequal(a1, a2)
  fprintf(1, 'attributes structs are equal\n')
else
  fprintf(1, 'checking individual attribute fields\n')
  an1 = fieldnames(a1);
  an2 = fieldnames(a2);

  % sort the field names
  [s1, i1] = sort(an1);
  [s2, i2] = sort(an2);
  if isequal(s1, s2), 
    fprintf(1, 'attribute field names are identical\n')
  else
    fprintf(1, 'checking individual attribute field names\n')
    for j = 1 : length(an1)
      if ~isequal(an1{i1(j)}, an2{i2(j)})
        fprintf(1, 'attribute names differ, index %d\n', j)
        display([an1{i1(j)}, '  ', an2{i2(j)}])
        continue
      end
    end
  end

  fprintf(1, 'checking individual attribute values\n')
  for j = 1 : length(an1)

    if isequal(an1{i1(j)}, 'product_name_timestamp'), continue, end

    if ~isequal(a1.(an1{i1(j)}), a2.(an2{i2(j)}))
      fprintf(1, 'attribute values differ, index %d\n', j)
      display([an1{i1(j)},' ', a1.(an1{i1(j)}),' ',a2.(an1{i2(j)})])
    end
  end
end

