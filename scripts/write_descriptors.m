function write_descriptors(path, descriptors)
% WRITE_DESCRIPTORS - Write the descriptors to a binary file.
%   path:
%       Path to descriptor file.
%   descriptors:
%       Floating point descriptors, where each row represents one
%       descriptor and each column represents one dimension of the
%       descriptor. For example, size(descriptors) = (1000, 128) contains
%       1000 descriptors of dimensionality 128. The data type of
%       the descriptors must be a single-precision real matrix.
%
% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

assert(isreal(descriptors) & isfloat(descriptors));

fid = fopen(path, 'w');
fwrite(fid, size(descriptors), 'int32');
fwrite(fid, descriptors', 'single');
fclose(fid);

end
