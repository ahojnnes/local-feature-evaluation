% Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

close all;
clear;
clc;

DATASET_NAMES = {'Fountain', 'Herzjesu', 'South-Building', ...
                 'Madrid_Metropolis', 'Gendarmenmarkt', 'Tower_of_London', ...
                 'Oxford5k', 'Alamo', 'Roman_Forum', 'ArtsQuad_dataset'};

for i = 1:length(DATASET_NAMES)
    %% Set the pipeline parameters.

    % TODO: Change this to where your dataset is stored. This directory should
    %       contain an "images" folder and a "database.db" file.
    DATASET_PATH = ['datasets/' DATASET_NAMES{i}];

    % TODO: Change this to where VLFeat is located.
    VLFEAT_PATH = 'vlfeat-0.9.20';

    % TODO: Change this to where the COLMAP build directory is located.
    COLMAP_PATH = 'colmap/build';

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

    %% TODO: Compute the keypoints and descriptors.

    feature_extraction_root_sift
    % feature_extraction_pca_sift
    % etc.

    %% Match the descriptors.
    %
    %  NOTE: - You must exhaustively match Fountain, Herzjesu, South Building,
    %          Madrid Metropolis, Gendarmenmarkt, and Tower of London.
    %        - You must approximately match Alamo, Roman Forum, Cornell.

    if num_images < 2000
        exhaustive_matching
    else
        VOCAB_TREE_PATH = fullfile(DATASET_PATH, 'Oxford5k/vocab-tree.bin');
        approximate_matching
    end
end
