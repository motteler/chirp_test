
% function prod_attr = read_cfgfile(cfg_file, prod_attr)

  cfg_file = 'chirp_airs.cfg';
% cfg_file = 'test1.cfg';

prod_attr = struct;

% this function name
fstr = mfilename;

% read the table
d1 = readtable(cfg_file, 'FileType', 'text', ...
               'CommentStyle', '#', ...
               'Delimiter', ':', ...
               'Whitespace', '\b\t ', ...
               'ReadVariableNames', false, ...
               'Format', 'auto');

% loop on attribute names
[m,n] = size(d1);
for i = 1 : m
  attr_name = d1{i,1};
  attr_name = strrep(attr_name{1}, ' ', '');
  attr_value = d1{i,2}; 
  attr_value = strrep(attr_value{1}, ' ', '');

  if isempty(attr_name)
    fprintf(1, '%s: missing attribute name, value %s\n', fstr, attr_value)
    continue
  end
  if isempty(attr_value)
    fprintf(1, '%s: missing attribute value, name %s\n', fstr, attr_name)
    continue
  end

% if ~isfield(prod_attr, attr_name)
%    fprintf(1, '%s: unexpected attribute name %s\n', fstr, attr_name)
%    continue
% end

  % assign value the attribute.  use try/catch to check for badly
  % formed attriubte names
  try
    prod_attr.(attr_name) = attr_value;
  catch
    fprintf(1, '%s: can''t assign field %s\n', fstr, attr_name)
  end

end

