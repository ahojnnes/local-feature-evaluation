function patches = extract_patches(image, keypoints, patch_radius)
% EXTRACT_PATCHES - Extract local patches for all keypoints in an image.
%   image:
%       Gray-scale single image containing the keypoints.
%   keypoints:
%       The keypoints with each row as x, y, scale, orientation.
%   patch_radius:
%       The desired patch radius in pixels.
%
%   patches:
%       The local patches around each keypoint with normalized intensities.
%
% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

if size(keypoints, 1) == 0
    patches = zeros(0, 2 * patch_radius + 1, 2 * patch_radius + 1);
    return
end

[~, patches, ~] = vl_covdet(image, ...
                            'frames', vl_frame2oell(keypoints'), ...
                            'descriptor', 'patch', ...
                            'patchresolution', patch_radius);
patches = reshape(patches, [2 * patch_radius + 1, 2 * patch_radius + 1, ...
                            size(keypoints, 1)]);
patches = permute(patches, [3, 1, 2]);

end
