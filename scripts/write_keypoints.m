function write_keypoints(path, keypoints)
% WRITE_KEYPOINTS - Write the keypoints to a binary file.
%   path:
%       Path to keypoint file.
%   keypoints:
%       Floating point keypoints, where each row represents one
%       keypoint and each column represents the x, y, scale and orientation
%       of the keypoint. For example, size(keypoints) = (1000, 4) contains
%       1000 keypoints. The data type of the keypoints must be a
%       single-precision real matrix.
%
% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

assert(isreal(keypoints) & isfloat(keypoints));
assert(size(keypoints, 2) == 4);

fid = fopen(path, 'w');
fwrite(fid, size(keypoints), 'int32');
fwrite(fid, keypoints', 'single');
fclose(fid);

end
