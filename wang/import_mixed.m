function [data] = import_mixed(filename, ncol, delim, hl, clist, cfmt)
%IMPORT_MIXED   Imports data from text file.
%   data = IMPORT_MIXED(filename, ncol) reads text from file which has
%   ncol columns of data, and returns a cell array with ncol elements. It
%   is able to import string columns mixed with number columns (which
%   Matlab's csvread, dlmread or importdata cannot do).
%
%   If ncol is not informed it will be guessed from the file, by reading the
%   file one extra time, line-by-line, and searching for the column
%   delimiters. This might add a considerable overhead for very large
%   files. 
%
%   IMPORT_MIXED(..., delim, hl, clist, cfmt) allows optional parameters
%   to fine tune how the text is imported: 
%
%      dlim(char)      column delimiter (default ',')
%
%      hl(integer)     number of header lines to skip (default 0)
%
%      clist(array)    columns to keep (default is all) 
%                      Ex.: [2, 4, 6] 
%
%      cfmt(cellarray) format (c-style) for each column to keep
%                      Ex.: {'s', '%f', '%d'}
%
%   HISTORY
%
%   24-March-2021 First version
%
%   CONTACT
%
%   hmjbarbosa@gmail.com
%   

if nargin<1
  error('Missing file name.')
end
if ~exist('ncol') | ~isnumeric(ncol) | isempty(ncol)
  ncol = 0;
end
if ~exist('delim') | ~ischar(delim) | isempty(delim)
  delim = ',';
end
if ~exist('hl') | ~isnumeric(hl) | isempty(hl)
  hl = 0;
end
if ~exist('clist') | ~isnumeric(clist)
  clist = [];
end
if ~exist('cfmt') | ~iscell(cfmt)
  cfmt = {};
end

% if formats are given
if numel(cfmt)
  % there must be one for each column
  if numel(clist) ~= numel(cfmt)
    error('List of columns and list of formats must have the same size.')
  end
end

% Check for number of columns
if (ncol ==0)
  fprintf('WARN: guessing number of columns, may take a while...')
  fid = fopen(filename,'r');
  nextLine = fgetl(fid);
  while ~isequal(nextLine, -1)
    ncol = max(ncol, numel(strfind(nextLine,delim)));
    nextLine = fgetl(fid);
  end
  ncol = ncol+1;
  fprintf(' found %d columns.\n', ncol);
  fclose(fid);
end

% Format to read columns

% horiz cell array with ncol * '%s'
tmp = cellstr(repmat('%s',ncol,1))'; 
% modify format of special columns
if numel(clist)>0
  tmp(clist) = cfmt;
end
% convert cell array to string
fmt = horzcat(tmp{:});

% Open the text file.
fid = fopen(filename,'r');

% Read all file. Size of output is 1 x ncol
data = textscan(fid, fmt, 'Delimiter', delim, 'HeaderLines', hl, 'ReturnOnError', false);

% Close the text file.
fclose(fid);

% Keep only some columns
if numel(clist)>0
  data = data(1, clist);
end

