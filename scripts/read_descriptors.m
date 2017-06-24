function descriptors = read_descriptors(path)
% READ_DESCRIPTOR - Read the descriptors from a binary file.
%   path:
%       Path to descriptor file.
%
%   keypoints:
%       The descriptor read from the file.
%
% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

fid = fopen(path, 'r');
shape = fread(fid, 2, 'int32');
descriptors = fread(fid, prod(shape), 'float32');
descriptors = reshape(descriptors, [shape(2), shape(1)])';
fclose(fid);

end
