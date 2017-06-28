% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

close all;
clear;
clc;

%% Set the pipeline parameters.

% TODO: Change this to where your dataset is stored. This directory should
%       contain an "images" folder and a "database.db" file.
DATASET_PATH = '/Users/jsch/Desktop/Fountain';

% TODO: Change this to where VLFeat is located.
VLFEAT_PATH = '/Users/jsch/Downloads/vlfeat-0.9.20';

% Radius of local patches around each keypoint.
PATCH_RADIUS = 32;

% Whether to run matching on GPU.
MATCH_GPU = gpuDeviceCount() > 0;

% Number of images to match in one block.
MATCH_BLOCK_SIZE = 50;

% Maximum distance ratio between first and second best matches.
MATCH_MAX_DIST_RATIO = 0.8;

% Mnimum number of matches between two images.
MIN_NUM_MATCHES = 15;

%% Setup the pipeline environment.

run(fullfile(VLFEAT_PATH, 'toolbox/vl_setup'));

IMAGE_PATH = fullfile(DATASET_PATH, 'images');
KEYPOINT_PATH = fullfile(DATASET_PATH, 'keypoints');
DESCRIPTOR_PATH = fullfile(DATASET_PATH, 'descriptors');
MATCH_PATH = fullfile(DATASET_PATH, 'matches');
DATABASE_PATH = fullfile(DATASET_PATH, 'database.db');

%% Create the output directories.

if ~exist(KEYPOINT_PATH, 'dir')
    mkdir(KEYPOINT_PATH);
end
if ~exist(DESCRIPTOR_PATH, 'dir')
    mkdir(DESCRIPTOR_PATH);
end
if ~exist(MATCH_PATH, 'dir')
    mkdir(MATCH_PATH);
end

%% Extract the image names and paths.

image_files = dir(IMAGE_PATH);
num_images = length(image_files) - 2;
image_names = cell(num_images, 1);
image_paths = cell(num_images, 1);
keypoint_paths = cell(num_images, 1);
descriptor_paths = cell(num_images, 1);
for i = 3:length(image_files)
    image_name = image_files(i).name;
    image_names{i-2} = image_name;
    image_paths{i-2} = fullfile(IMAGE_PATH, image_name);
    keypoint_paths{i-2} = fullfile(KEYPOINT_PATH, [image_name '.bin']);
    descriptor_paths{i-2} = fullfile(DESCRIPTOR_PATH, [image_name '.bin']);
end

%% Compute the keypoints and descriptors.

delete(gcp('nocreate'));
parpool(maxNumCompThreads());

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
    if ndims(image) == 2
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

    % TODO: Compute the descriptors for the extracted patches. Here, we
    %       simply compute SIFT descriptors for all patches using VLFeat.
    [~, descriptors] = vl_covdet(image, 'Frames', keypoints', ...
                                 'Descriptor', 'SIFT');
    descriptors = descriptors';

    % Make sure that each keypoint has one descriptor.
    assert(size(keypoints, 1) == size(descriptors, 1));

    % Write the descriptors to disk for matching.
    write_descriptors(descriptor_paths{i}, descriptors);

    fprintf(' in %.3fs\n', toc);
end

%% Exhaustively match the descriptors
%
%  NOTE: You must exhaustively match Fountain, Herzjesu, South Building,
%        Madrid Metropolis, Gendarmenmarkt, and Tower of London.

num_blocks = ceil(num_images / MATCH_BLOCK_SIZE);
num_pairs_per_block = MATCH_BLOCK_SIZE * (MATCH_BLOCK_SIZE - 1) / 2;

for start_idx1 = 1:MATCH_BLOCK_SIZE:num_images
    end_idx1 = min(num_images, start_idx1 + MATCH_BLOCK_SIZE - 1);
    for start_idx2 = 1:MATCH_BLOCK_SIZE:num_images
        end_idx2 = min(num_images, start_idx2 + MATCH_BLOCK_SIZE - 1);

        fprintf('Matching block [%d/%d, %d/%d]', ...
                int64(start_idx1 / MATCH_BLOCK_SIZE) + 1, num_blocks, ...
                int64(start_idx2 / MATCH_BLOCK_SIZE) + 1, num_blocks);

        tic;

        % Read the descriptors for current block of images.
        descriptors = containers.Map('KeyType', 'int32', ...
                                     'ValueType', 'any');
        for idx = [start_idx1:end_idx1, start_idx2:end_idx2]
            if descriptors.isKey(idx)
                continue;
            end
            image_descriptors = single(read_descriptors(descriptor_paths{idx}));
            if MATCH_GPU
                descriptors(idx) = gpuArray(image_descriptors);
            else
                descriptors(idx) = image_descriptors;
            end
        end

        % Match and write the current block of images.
        for idx1 = start_idx1:end_idx1
            for idx2 = start_idx2:end_idx2
                block_id1 = mod(idx1, MATCH_BLOCK_SIZE);
                block_id2 = mod(idx2, MATCH_BLOCK_SIZE);
                if (idx1 > idx2 && block_id1 <= block_id2) ...
                        || (idx1 < idx2 && block_id1 < block_id2)
                    % Order the indices to avoid duplicate pairs.
                    if idx1 < idx2
                        oidx1 = idx1;
                        oidx2 = idx2;
                    else
                        oidx1 = idx2;
                        oidx2 = idx1;
                    end

                    % Check if matches already computed.
                    matches_path = fullfile(...
                        MATCH_PATH, sprintf('%s---%s.bin', ...
                        image_names{oidx1}, image_names{oidx2}));
                    if exist(matches_path, 'file')
                        continue;
                    end

                    % Match the descriptors.
                    matches = match_descriptors(descriptors(oidx1), ...
                                                descriptors(oidx2), ...
                                                MATCH_MAX_DIST_RATIO);

                    % Write the matches.
                    if size(matches, 1) < MIN_NUM_MATCHES
                        matches = zeros(0, 2, 'uint32');
                    end
                    write_matches(matches_path, matches);
                end
            end
        end

        fprintf(' in %.3fs\n', toc);
    end
end
