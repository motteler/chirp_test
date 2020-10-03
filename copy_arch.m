%
% replacement for copyfile, for copying files out of the deployable
% archive.  needed because matlab copyfile does not see the archive
% path.  
%

function copy_arch(src, dst)

% fprintf(1, 'ctfroot = %s\n', ctfroot)
% fprintf(1, 'src = %s\n', src)

if isdeployed && src(1) ~= '/'
  % we have a deployable archive and a name or relative path.
  % check for a path to src in the deployable archive; if we
  % find exactly 1 instance of src, add the archive path.
  t1 = dir(fullfile(ctfroot, '*', src));
  if numel(t1) == 1 && exist(fullfile(t1.folder, t1.name)) == 2
    src = fullfile(t1.folder, t1.name);
%   fprintf(1, 'updated src = %s\n', src)
  end
end

% call copyfile
copyfile(src, dst);

