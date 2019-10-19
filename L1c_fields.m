
% adir = '/asl/data/airs/L1C/2016/126';
% agran = 'AIRS.2016.05.05.231.L1C.AIRS_Rad.v6.1.2.0.G16127122356.hdf';

adir = '/asl/data/airs/L1C/2018/001';
agran = '/AIRS.2018.01.01.220.L1C.AIRS_Rad.v6.1.2.0.G18002101815.hdf';
afile = fullfile(adir, agran);

xx = hdfinfo(afile);

fprintf(1, '-- Geo -----------------------------------------------\n')
xx.Vgroup.Vgroup(1)
for i = 1 : 3
  xx.Vgroup.Vgroup(1).SDS(i)
end

fprintf(1, '-- Data SDS -------------------------------------------\n')
xx.Vgroup.Vgroup(2)
% Data fields
for i = 1 : 27
  xx.Vgroup.Vgroup(2).SDS(i)
end

fprintf(1, '-- Data Vdata -----------------------------------------\n');
% Vdata fields
for i = 1 : 17
  xx.Vgroup.Vgroup(2).Vdata(i)
end

fprintf(1, '-- Attributes -----------------------------------------\n');
% Attributes
xx.Attributes(5).Value

