%
% NAME
%   read_airs_h4 - read an AIRS HDF4 granule
%
% SYNOPSIS
%   d1 = read_airs_h4(agran) 
%
% INPUT
%   agran - AIRS input granule file
%
% OUTPUT
%   d1 - struct with AIRS data
%
% Data is returned in column order, with h4 data types and the h4
% variable names as fields.  read_airs_h4 is faster than looping on
% hdfinfo output but not as fast as simply calling hdfread, if only
% a few fields are needed.
%
% hdfread does not return errors and so needs a try/catch wrapper;
% it's probably simpler to do that at a higher level with try/catch
% around the read_airs_h4 call.
%
% AUTHOR
%   H. Motteler, 12 July 2019
%

function d1 =read_airs_h4(agran)

d1 = struct;

% Full Swath fields (2645 x 90 x 135 arrays)
d1.radiances = permute(hdfread(agran, 'radiances'), [3,2,1]);
d1.NeN       = permute(hdfread(agran, 'NeN'),       [3,2,1]);
d1.L1cProc   = permute(hdfread(agran, 'L1cProc'),   [3,2,1]);
d1.L1cSynthReason = permute(hdfread(agran, 'L1cSynthReason'), [3,2,1]);

% Full Swath fields (90 x 135 arrays)
d1.Time      = permute(hdfread(agran, 'Time'),      [2,1]);
d1.Latitude  = permute(hdfread(agran, 'Latitude'),  [2,1]);
d1.Longitude = permute(hdfread(agran, 'Longitude'), [2,1]);
d1.scanang   = permute(hdfread(agran, 'scanang'),   [2,1]);
d1.satzen    = permute(hdfread(agran, 'satzen'),    [2,1]);
d1.satazi    = permute(hdfread(agran, 'satazi'),    [2,1]);
d1.solzen    = permute(hdfread(agran, 'solzen'),    [2,1]);
d1.solazi    = permute(hdfread(agran, 'solazi'),    [2,1]);
d1.landFrac  = permute(hdfread(agran, 'landFrac'),  [2,1]);
d1.topog     = permute(hdfread(agran, 'topog'),     [2,1]);
d1.topog_err = permute(hdfread(agran, 'topog_err'), [2,1]);
d1.state     = permute(hdfread(agran, 'state'),     [2,1]);

% Along-Track Fields (135 x 1 arrays)
d1.sat_lat   = hdfread(agran, 'sat_lat');
d1.sat_lon   = hdfread(agran, 'sat_lon');
d1.nadirTAI  = hdfread(agran, 'nadirTAI');
d1.satheight = hdfread(agran, 'satheight');
d1.glintlat  = hdfread(agran, 'glintlat');
d1.glintlon  = hdfread(agran, 'glintlon');
d1.scan_node_type = hdfread(agran, 'scan_node_type');

% d1.satgeoqa   = hdfread(agran, 'satgeoqa');
% d1.glintgeoqa = hdfread(agran, 'glintgeoqa');
% d1.moongeoqa  = hdfread(agran, 'moongeoqa');

% drop cell array wrappers
d1.sat_lat        = d1.sat_lat{1}';
d1.sat_lon        = d1.sat_lon{1}';
d1.nadirTAI       = d1.nadirTAI{1}';
d1.satheight      = d1.satheight{1}';
d1.glintlat       = d1.glintlat{1}';   
d1.glintlon       = d1.glintlon{1}';
d1.scan_node_type = d1.scan_node_type{1}';

% Per-Granule fields (2645 x 1 arrays)
d1.nominal_freq   = hdfread(agran, 'nominal_freq');
d1.ChanID         = hdfread(agran, 'ChanID');
d1.ChanMapL1b     = hdfread(agran, 'ChanMapL1b');
d1.L1cNumSynth    = hdfread(agran, 'L1cNumSynth');

% drop cell array wrappers
d1.nominal_freq = d1.nominal_freq{1}';
d1.ChanID       = d1.ChanID{1}';
d1.ChanMapL1b   = d1.ChanMapL1b{1}';
d1.L1cNumSynth  = d1.L1cNumSynth{1}';

