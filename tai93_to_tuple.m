%
% take tai93 to utc_tuple (from CHIRP CDL spec)
%

function tuple = tai93_to_tuple(tai93)

% datevec flattens its input to m x 6 and returns y m d h m s,
% with s = fractional seconds
t1 = datevec(airs2dnum(tai93));

% truncated seconds
s1 = t1(:, 6);
s2 = floor(s1);

% truncated milliseconds
ms1 = (s1 - s2) * 1000;
ms2 = floor(ms1);

% truncated microseconds
us1 = (ms1 - ms2) * 1000;
us2 = floor(us1);

tuple = [t1(:, 1:5), s2, ms2, us2];   
tuple = uint16(tuple)';


% % TEST w/ increment
% dt = 1e-4;
% t1a = datevec(airs2dnum(tai93 + dt));
% 
% % truncated seconds
% s1a = t1a(:, 6);
% s2a = floor(s1a);
% 
% % truncated milliseconds
% ms1a = (s1a - s2a) * 1000;
% ms2a = floor(ms1a);
% 
% % truncated microseconds
% us1a = (ms1a - ms2a) * 1000;
% us2a = floor(us1a);
% 
% xx = us2a - us2;
% xx(1:8)'
% 
% yy = ms2a - ms2;
% yy(1:8)'

