Instructions
============

If you want to evaluate your own descriptors on our image-based reconstruction
benchmark, please follow steps 1-4 below to download the datasets and to
run the benchmark. In addition, more detailed instructions for each individual
step can be found at the end of this document. It is recommended to first run
the pipeline on a smaller dataset (e.g., Fountain or Herzjesu) to test whether
the computed results make sense.

1. **Requirements:**

   - Computer with CUDA-enabled GPU
   - Matlab R2016b or newer (for GPU feature matching)
   - [VLFeat](http://www.vlfeat.org/) toolbox for Matlab
   - [COLMAP](https://github.com/colmap/colmap):

         git clone https://github.com/ahojnnes/local-feature-evaluation.git
         git clone https://github.com/colmap/colmap
         cd colmap
         git checkout 58d966c
         cp ../local-feature-evaluation/colmap-tools/* src/tools
         mkdir build
         cd build
         cmake .. -DTESTS_ENABLED=OFF
         make

2. **Download the datasets:**

       mkdir datasets
       cd datasets

       wget https://cvg-data.inf.ethz.ch/local-feature-evaluation-schoenberger2017/Databases.tar.gz
       wget https://cvg-data.inf.ethz.ch/local-feature-evaluation-schoenberger2017/Strecha-Fountain.zip
       wget https://cvg-data.inf.ethz.ch/local-feature-evaluation-schoenberger2017/Strecha-Herzjesu.zip
       wget https://cvg-data.inf.ethz.ch/local-feature-evaluation-schoenberger2017/South-Building.zip
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Madrid_Metropolis.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Gendarmenmarkt.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Tower_of_London.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Alamo.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Roman_Forum.tar
       wget http://vision.soic.indiana.edu/disco_files/ArtsQuad_dataset.tar
       wget http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/oxbuild_images.tgz

3. **Extract the datasets:**

       tar xvfz Databases.tar.gz
       unzip Strecha-Fountain.zip
       unzip Strecha-Herzjesu.zip
       unzip South-Building.zip
       tar xvf images.Madrid_Metropolis.tar
       tar xvf images.Gendarmenmarkt.tar
       mv home/wilsonkl/projects/SfM_Init/dataset_images/Gendarmenmarkt/images Gendarmenmarkt/images
       rm -r home
       tar xvf images.Madrid_Metropolis.tar
       tar xvf images.Tower_of_London.tar
       tar xvf images.Alamo.tar
       tar xvf images.Roman_Forum.tar
       tar xvf ArtsQuad_dataset.tar
       mkdir -p Oxford5k/images
       cd Oxford5k/images
       tar xfvz ../../oxbuild_images.tgz
       cd ../..

4. **Download and extract keypoints:**

   If you evaluate just a feature descriptor without a feature detection
   component, you should use the provided SIFT keypoints:

       wget https://cvg-data.inf.ethz.ch/local-feature-evaluation-schoenberger2017/Keypoints.tar.gz
       tar xvfz Keypoints.tar.gz

5. **Run the evaluation:**

   You can now run the evaluation scripts for every dataset by first running the
   matching pipeline using the Matlab script ``scripts/matching_pipeline.m``.
   All locations that require changes by you (the user) are marked with ``TODO``
   in the Matlab script.

   After finishing the matching pipeline, run the reconstruction using:

       python scripts/reconstruction_pipeline.py \
           --dataset_path datasets/Fountain \
           --colmap_path colmap/build/src/exe

   At the end of the reconstruction pipeline output, you should see all
   relevant statistics of the benchmark. For example:

       ==============================================================================
       Raw statistics
       ==============================================================================
       {'num_images': 11, 'num_inlier_pairs': 55, 'num_inlier_matches': 120944}
       {'num_reg_images': 11, 'num_sparse_points': 14472, 'num_observations': 68838, 'mean_track_length': 4.756633, 'num_observations_per_image': 6258.0, 'mean_reproj_error': 0.384562, 'num_dense_points': 298634}

       ==============================================================================
       Formatted statistics
       ==============================================================================
       | Fountain | METHOD | 11 | 11 | 14472 | 68838 | 4.756633 | 6258.0 | 0.384562 | 298634 |  |  |  |  | 55 | 120944 |

   Alternatively, you can find more details about each individual step in the
   pipeline scripts above in the detailed instructions below.


Detailed Instructions
---------------------

1. **Compute the keypoints:**

   The keypoints for each image ``${IMAGE_NAME}`` in the ``images`` folder are
   stored in a binary file ``${IMAGE_NAME}.bin`` in the ``keypoints`` folder.

     1. *Using the provided SIFT keypoints:*

            wget https://cvg-data.inf.ethz.ch/local-feature-evaluation-schoenberger2017/Keypoints.tar.gz
            tar xvfz Keypoints.tar.gz

     2. *Using your own keypoints:*

        The keypoints for each image are stored in a binary file of the format:

            <N><D><KEY_1><KEY_2><...><KEY_N>

        where ``N`` is the number of keypoints as a signed 4-byte integer,
        ``D = 4`` is a signed 4-byte integer denoting the number of keypoint
        properties, and ``KEY_I`` is one single-precision floating point vector
        with ``D = 4`` elements. In total, this binary file should consist of
        two signed 4-byte integers followed by ``N x D`` single-precision
        floating point values storing the ``N x 4`` keypoint matrix in row-major
        format. In this matrix, each row contains the ``x``, ``y``, ``scale``,
        ``orientation`` properties of the keypoint.

   Note that we provide the Matlab function ``scripts/read_keypoints.m`` and
   ``scripts/write_keypoints.m`` to read and write keypoints:

       keypoints = read_keypoints('Fountain/keypoints/0000.png.bin');
       write_keypoints('Fountain/keypoints/0000.png.bin', keypoints);

   The corresponding patches of each keypoint can be easily extracted using
   the provided ``scripts/extract_patches.m`` Matlab function:

       image = single(rgb2gray(image));
       patches = extract_patches(image, keypoints, 32);

   where ``32`` is the radius of the extracted patch centered at the keypoint.

2. **Compute the descriptors:**

   For each image ``images/${IMAGE_NAME}`` and each keypoint in
   ``keypoints/${IMAGE_NAME}.bin``, you must save a corresponding descriptor
   file ``descriptors/${IMAGE_NAME}.bin`` in the following format:

       <N><D><DESC_1><DESC_2><...><DESC_N>

   where ``N`` is the number of descriptors as a signed 4-byte integer, ``D`` is
   the dimensionality as a signed 4-byte integer, and ``DESC_I`` is one
   single-precision floating point vector with ``D`` elements. In total, this
   binary file should consist of two signed 4-byte integers followed by
   ``N x D`` single-precision floating point values storing the ``N x D``
   descriptor matrix in row-major format. Note that we provide the Matlab
   functions ``scripts/read_descriptors.m`` and ``scripts/write_descriptors.m``
   to read and write your descriptors:

       keypoints = read_keypoints('Fountain/keypoints/0000.png.bin');
       patches = extract_patches('Fountain/images/0000.png', keypoints, 32);
       descriptors = your_descriptor_function(keypoints, patches);
       assert(size(keypoints, 1) == size(descriptors, 1));
       write_descriptors('Fountain/descriptors/0000.png.bin', descriptors);

3. **Build the visual vocabulary:**

   For matching the descriptors of the larger datasets, you need to build a
   visual vocabulary for your descriptor. This is done using the Oxford5k
   dataset. First, you must compute features for all images in the dataset
   as described in the previous steps. Note that if you use your own keypoint
   detector, every image should have around 1000 features on average in order
   to obtain a good quantization of the descriptor space. You can then build
   a visual vocabulary tree using the ``vocab_tree_builder_float`` binary:

       ./colmap/build/src/tools/vocab_tree_builder_float \
           --descriptor_path Oxford5k/descriptors \
           --database_path Oxford5k/database.db \
           --vocab_tree_path Oxford5k/vocab-tree.bin

   Note that if your descriptors have a dimensionality different from 128, you
   have to change the ``kDescDim`` values in the ``vocab_tree_builder_float.cc``
   and ``vocab_tree_retriever_float.cc`` source files accordingly.

4. **Match the descriptors:**

   As an input to image-based reconstruction, you need to compute 2D-to-2D
   feature correspondences between pairs of images. For the smaller datasets
   (Fountain, Herzjesu, South Building, Madrid Metropolis, Gendarmenmarkt, Tower
   of London), this must be done exhaustively for all image pairs. For the
   larger datasets (Alamo, Roman Forum, Cornell), this must be done by matching
   each image against its nearest neighbor image using the Bag-of-Words image
   retrieval system of COLMAP. First, make sure that all keypoints and
   descriptors exist. Then, run the corresponding section in the
   ``scripts/matching_pipeline.m`` script. It is strongly recommended that you
   run this step on a machine with a CUDA-enabled GPU to speedup the matching
   process. The benchmark pipeline script should run the matching fully
   automatically end-to-end, but you can find additional details below.

     1. Exhaustive matching:
        Note that this step can take a significant amount of time. For example,
        the largest dataset for exhaustive matching (Madrid Metropolis) takes
        around 16 hours to match on a single NVIDIA Titan X GPU. It is therefore
        recommended to check whether everything works on one of the smaller
        datasets before running the bigger datasets. The code for this
        matching module is in ``scripts/exhaustive_matching.m``.
     2. Nearest neighbor matching:
        First, you need to execute the image retrieval pipeline to find
        the most similar image in the dataset for every image in the dataset:

            ./colmap/build/src/tools/vocab_tree_retriever_float \
                --descriptor_path Roman_Forum/descriptors \
                --database_path Roman_Forum/database.db \
                --vocab_tree_path Roman_Forum/vocab-tree.bin \
                > Roman_Forum/retrieval.txt

        Then, run the ``scripts/approximate_matching.m`` Matlab script.

   In both cases, the output will be written to the ``matches`` folder inside
   the dataset folder. The matches for image pair ``${IMAGE_NAME1}`` and
   ``${IMAGE_NAME2}`` must be written to the
   ``matches/${IMAGE_NAME1}---${IMAGE_NAME2}.bin`` binary file in the format:

       <N><D><MATCH_1><MATCH_2><...><MATCH_N>

   where ``N`` is the number of matches as a signed 4-byte integer, ``D = 2``
   is a signed 4-byte integer denoting the number of columns of the match
   matrix, and ``MATCH_I`` is a ``uint32`` vector of two elements specifying
   the zero-based indices of the corresponding keypoints in ``${IMAGE_NAME1}``
   and ``${IMAGE_NAME2}``. In total, this binary file should consist of
   two signed 4-byte integers followed by ``N x 2`` ``uint32`` values storing
   the ``N x 2`` match matrix in row-major format. In this matrix, each row
   contains the indices of one match.

   Note that we provide the Matlab function ``scripts/write_matches.m``
   to write the matches in this format:

       write_matches('Fountain/matches/0000.png---0001.png.bin', matches);

   Here, the matches matrix contains the matching keypoints using one-based
   indexing as used by Matlab:

       keypoints1 = read_keypoints('Fountain/keypoints/0000.png.bin');
       keypoints2 = read_keypoints('Fountain/keypoints/0001.png.bin');
       matching_keypoints1 = keypoints1(matches(:,1));
       matching_keypoints2 = keypoints2(matches(:,2));

5. **Import the features and matches into COLMAP:**

   Run the Python script ``scripts/colmap_import.py``:

       python scripts/colmap_import.py --dataset_path path/to/Fountain

   You can now verify the features and matches using COLMAP by opening the
   COLMAP GUI and clicking ``Processing > Database management``. By selecting
   an image and clicking ``Show image`` you can see the detected keypoints.
   By clicking ``Show matches`` you can see the feature matches for each image.

   At this point, the feature matches are not geometrically verified, which is
   why there are no inlier matches in the database. To verify the matches,
   you must run the COLMAP ``matches_importer`` executable:

       ./colmap/build/src/exe/matches_importer \
           --database_path path/to/Fountain/database.db \
           --match_list_path path/to/Fountain/image-pairs.txt \
           --match_type pairs

   Alternatively, you can run the same operation from the COLMAP GUI by
   clicking ``Processing > Feature matching`` and then selecting the ``Custom``
   tab. Here, select ``Image pairs`` as match type and select the
   ``path/to/Fountain/image-pairs.txt`` as the match list path.
   Then, run the geometric verification by clicking ``Run``.

   To visualize the geometrically verified inlier matches, you can again
   use the database management tool. Alternatively, you can visualize the
   successfully verified image pairs by clicking ``Extras > Show match matrix``.

6. **Run the sparse reconstruction:**

    1. From the command-line:

           ./colmap/build/src/exe/colmap mapper \
               --database_path path/to/Fountain/database.db \
               --image_path path/to/Fountain/images \
               --export_path path/to/Fountain/sparse

    2. From the GUI:
       Open the COLMAP GUI, click ``File > New project``, ``Open`` the
       ``path/to/Fountain/database.db`` database file and image path.
       Next, click ``Reconstruction > Start reconstruction``.

7. **Run the dense reconstruction:**

    Now, we run the dense reconstruction on the reconstructed sparse model
    with the most registered images. To find the largest sparse model,
    you can use the command:

        ./colmap/build/src/exe/model_analyzer \
            --path path/to/Fountain/sparse/0

    Here, ``0`` is the folder containing the 0-th reconstructed sparse model.
    Then, execute the following commands on the largest sparse model, as
    determined previously (in this case it is the 0-th model):

        mkdir -p path/to/Fountain/dense/0
        ./colmap/build/src/exe/colmap image_undistorter \
            --image_path path/to/Fountain/images \
            --input_path path/to/Fountain/sparse/0 \
            --export_path path/to/Fountain/dense/0 \
            --max_image_size 1200
        ./colmap/build/src/exe/colmap patch_match_stereo \
            --workspace_path path/to/Fountain/dense/0 \
            --PatchMatchStereo.geom_consistency false
        ./colmap/build/src/exe/colmap stereo_fusion \
            --workspace_path path/to/Fountain/dense/0 \
            --StereoFusion.min_num_pixels 5 \
            --input_type photometric \
            --output_path path/to/Fountain/dense/0/fused.ply

8. **Extract the statistics**:

    If you did not execute the evaluation script, you must now extract the
    relevant statistics from the output manually.
