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

    % TODO: Replace this with your keypoint detector. The resultding
    %       keypoints matrix should have shape N x 4, where each row
    %       contains the keypoint properties x, y, scale, orientation.
    %       Note that only x and y are necessary for the reconstruction
    %       benchmark while scale and orientation are only used for
    %       extracting local patches around each detected keypoint.
    %       If you implement your own keypoint detector and patch
    %       extractor, then you can simply set scale and orientation to 0.
    %       Here, we simply detect SIFT keypoints using VLFeat.
    % keypoints = vl_sift(image)';
    % write_keypoints(keypoint_paths{i}, keypoints);
    keypoints = read_keypoints(keypoint_paths{i});

    % Extract the local patches for all keypoints.
    patches = extract_patches(image, keypoints, PATCH_RADIUS);

    % TODO: Extract the descriptors from the patches.
    descriptors = my_custom_descriptor_extractor(patches);

    % Make sure that each keypoint has one descriptor.
    assert(size(keypoints, 1) == size(descriptors, 1));

    % Write the descriptors to disk for matching.
    write_descriptors(descriptor_paths{i}, descriptors);

    fprintf(' in %.3fs\n', toc);
end
