function [data] = import_abs_AERONET(filename)
% Reads a AERONET file and returns the columns: date, time, AAE440, 675, 870
% Uses the low-level import_mixed() function. 

if nargin<1
  error('Missing file name.')
end

% configure for AERONET file
ncol = 45;
delim = ',';
hl = 7;
clist = [2, 3, 6, 7, 8];
cfmt = {'%s','%s','%f','%f','%f'};

data = import_mixed(filename, ncol, delim, hl, clist, cfmt);

