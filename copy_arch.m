%
% replacement for copyfile, for copying files out of the deployable
% archive.  needed because matlab copyfile does not see the archive
% path.  
%

function [suc, msg, mid] = copy_arch(src, dst)

if ~isdeployed
  [suc, msg, mid] = copyfile(src, dst);
else
% fprintf(1, 'ctfroot = %s\n', ctfroot)
% fprintf(1, 'src = %s\n', src)
% fprintf(1, 'dst = %s\n', dst)

  % path to src in the deployable archive
  t1 = dir(fullfile(ctfroot, '*', src));

  % if we find exactly 1 instance of src, use it
  if numel(t1) == 1 && exist(fullfile(t1.folder, t1.name)) == 2
    t2 = fullfile(t1.folder, t1.name);
%   fprintf(1, 't2 = %s\n', t2)
    [suc, msg, mid] = copyfile(t2, dst);
  else
    error(sprintf('can''t find %s in deployable archive %s\n', src, ctfroot))
  end
end

