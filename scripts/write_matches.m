function write_matches(path, matches)
% WRITE_MATCHES - Write the matches to a binary file.
%   path:
%       Path to match file.
%   matches:
%       Integer match indices, where each row represents one
%       match pair between two images.
%
% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

assert(isreal(matches) & isinteger(matches));
assert(size(matches, 2) == 2);

% Convert from 1-based to 0-based indexing.
matches = matches - 1;

fid = fopen(path, 'w');
fwrite(fid, size(matches), 'int32');
fwrite(fid, matches', 'uint32');
fclose(fid);

end
