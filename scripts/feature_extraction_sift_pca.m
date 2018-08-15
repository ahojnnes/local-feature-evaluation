% Note that for PCA-SIFT, the descriptor dimension changes and you have to set
% kDescDim = 128 in the colmap-tools source code.

load(fullfile(fileparts(mfilename('fullpath')), '../data/pca-sift.mat'));

pool = gcp('nocreate');
if isempty(pool)
    pool = parpool(maxNumCompThreads());
end

parfor i = 1:num_images
    fprintf('Computing features for %s [%d/%d]', ...
            image_names{i}, i, num_images);

    if exist(keypoint_paths{i}, 'file') ...
            && exist(descriptor_paths{i}, 'file')
        fprintf(' -> skipping, already exist\n');
        continue;
    end

    tic;

    % Read the image for keypoint detection, patch extraction and
    % descriptor computation.
    image = imread(image_paths{i});
    if ismatrix(image)
        image = single(image);
    else
        image = single(rgb2gray(image));
    end

    % Read the pre-computed SIFT keypoints.
    keypoints = read_keypoints(keypoint_paths{i});

    % Compute the descriptors for the detected keypoints.
    if size(keypoints, 1) == 0
        descriptors = zeros(0, 80);
    else
        % Extract the descriptors from the patches.
        [~, descriptors] = vl_covdet(image, 'Frames', keypoints', ...
                                     'Descriptor', 'SIFT');
        % Perform PCA-SIFT projection and extract top 80 principal components.
        descriptors = pca_sift_eigvecs * double(descriptors);
        descriptors = single(data.descriptors(1:80,:))';
    end

    % Make sure that each keypoint has one descriptor.
    assert(size(keypoints, 1) == size(descriptors, 1));

    % Write the descriptors to disk for matching.
    write_descriptors(descriptor_paths{i}, descriptors);

    fprintf(' in %.3fs\n', toc);
end
