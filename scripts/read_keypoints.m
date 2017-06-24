function keypoints = read_keypoints(path)
% READ_KEYPOINTS - Read the keypoints from a binary file.
%   path:
%       Path to keypoint file.
%
%   keypoints:
%       The keypoints read from the file.
%
% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

fid = fopen(path, 'r');
shape = fread(fid, 2, 'int32');
keypoints = fread(fid, prod(shape), 'float32');
keypoints = reshape(keypoints, [shape(2), shape(1)])';
fclose(fid);

assert(size(keypoints, 2) == 4);

end
