%
% NAME
%   chirp_batch -- run chirp translation on doy = job array ID
%
% SYNOPSIS
%   chirp_batch(src, year)
%
% src values include
%   airs_L1c, cris_npp
%

function chirp_batch(src, year)

more off
addpath /asl/packages/ccast/motmsc/time

jobid = str2num(getenv('SLURM_JOB_ID'));          % job ID
jarid = str2num(getenv('SLURM_ARRAY_TASK_ID'));   % job array ID
procid = str2num(getenv('SLURM_PROCID'));         % relative process ID
nprocs = str2num(getenv('SLURM_NTASKS'));         % number of tasks
nodeid = sscanf(getenv('SLURMD_NODENAME'), '%s'); % node name

doy = jarid;

if isleap(year), yend = 366; else, yend = 365; end
if doy > yend
  fprintf(1, 'chirp %s: ignoring %d doy %d\n', src, year, doy)
  return
end

fprintf(1, 'chirp %s: processing day %d, year %d, node %s\n', ...
            src, doy, year, nodeid);
fprintf(1, 'job ID %d\n', jobid)
fprintf(1, 'job array ID %d\n', jarid)
fprintf(1, 'process ID %d\n', procid)

switch src
  case 'airs_L1c', opts_airs_src(year, doy);
  case 'cris_npp', opts_cris_src(year, doy);
  otherwise, error('bad src spec')
end

