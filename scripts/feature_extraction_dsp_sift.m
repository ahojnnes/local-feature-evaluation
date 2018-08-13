DSP_MIN_SCALE = 1 / 6;
DSP_MAX_SCALE = 3;
DSP_NUM_SCALES = 10;

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
        descriptors = zeros(0, 128);
    else
        % Create DSP keypoints, sampled around the standard SIFT detections.
        num_keypoints = size(keypoints, 1);
        dsp_keypoints = zeros(4, num_keypoints, DSP_NUM_SCALES);
        dsp_scale_idx = 1;
        for dsp_scale = linspace(DSP_MIN_SCALE, DSP_MAX_SCALE, DSP_NUM_SCALES)
            dsp_keypoints([1 2 4],:,dsp_scale_idx) = keypoints(:,[1 2 4])';
            dsp_keypoints(3,:,dsp_scale_idx) = dsp_scale * keypoints(:,3)';
            dsp_scale_idx = dsp_scale_idx + 1;
        end

        % Transpose to VLFeat format.
        dsp_keypoints = reshape(dsp_keypoints, ...
                                [4, num_keypoints * DSP_NUM_SCALES]);

        % Extract the descriptors from the DSP keypoints.
        [~, descriptors] = vl_covdet(image, 'Frames', dsp_keypoints, ...
                                     'Descriptor', 'SIFT');

        % Aggregate the descriptors across all scales.
        descriptors = reshape(descriptors, ...
                              [128, num_keypoints, DSP_NUM_SCALES]);
        descriptors = mean(double(descriptors), 3)';
    end

    % Make sure that each keypoint has one descriptor.
    assert(size(keypoints, 1) == size(descriptors, 1));

    % Write the descriptors to disk for matching.
    write_descriptors(descriptor_paths{i}, descriptors);

    fprintf(' in %.3fs\n', toc);
end
