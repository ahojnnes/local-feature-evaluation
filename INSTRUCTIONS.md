Instructions
============

If you want to evaluate your own descriptors on our image-based reconstruction
benchmark, please follow steps 1 and 2 below and then follow the steps in the
Matlab script ``scripts/pipeline.m``. All locations that require changes by you
(the user) are marked with ``TODO`` in this script. In addition, more detailed
instructions for each individual step can be found below. It is recommended to
first run the pipeline on a smaller dataset (e.g., Fountain or Herzjesu) to test
whether the computed results make sense.

0. Requirements

   - Computer with CUDA-enabled GPU
   - Matlab R2016b or newer (for GPU feature matching)
   - [VLFeat](http://www.vlfeat.org/) toolbox for Matlab
   - [COLMAP](https://github.com/colmap/colmap) version 3.1:

         git clone https://github.com/colmap/colmap
         git checkout 3.1
         cd colmap
         mkdir build
         cd build
         cmake ..
         make -j

1. **Download the datasets:**

       wget http://cvg.ethz.ch/research/local-feature-evaluation/Databases.tar.gz
       wget http://cvg.ethz.ch/research/local-feature-evaluation/Strecha-Fountain.zip
       wget http://cvg.ethz.ch/research/local-feature-evaluation/Strecha-Herzjesu.zip
       wget http://cvg.ethz.ch/research/local-feature-evaluation/South-Building.zip
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Madrid_Metropolis.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Gendarmenmarkt.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Tower_of_London.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Alamo.tar
       wget http://landmark.cs.cornell.edu/projects/1dsfm/images.Roman_Forum.tar
       wget http://vision.soic.indiana.edu/disco_files/ArtsQuad_dataset.tar
       wget http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/oxbuild_images.tgz

2. **Extract the datasets:**

       tar xvfz Databases.tar.gz
       unzip Strecha-Fountain.zip
       unzip Strecha-Herzjesu.zip
       unzip South-Building.zip
       tar xvf images.Madrid_Metropolis.tar
       tar xvf images.Gendarmenmarkt.tar
       mv home/wilsonkl/projects/SfM_Init/dataset_images/Gendarmenmarkt Gendarmenmarkt
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

3. **Compute the keypoints:**

   The keypoints for each image ``${IMAGE_NAME}`` in the ``images`` folder are
   stored in a binary file ``${IMAGE_NAME}.bin`` in the ``keypoints`` folder.

     1. *Using the provided SIFT keypoints:*

            wget http://cvg.ethz.ch/research/local-feature-evaluation/Keypoints.tar.gz
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

       patches = extract_patches('Fountain/images/0000.png', keypoints, 32);

   where ``32`` is the radius of the extracted patch centered at the keypoint.

4. **Compute the descriptors:**

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

5. **Match the descriptors:**

   As an input to image-based reconstruction, you need to compute 2D-to-2D
   feature correspondences between pairs of images. For the smaller datasets
   (Fountain, Herzjesu, South Building, Madrid Metropolis, Gendarmenmarkt,
   Tower of London), this must be done exhaustively for all image pairs. For
   the larger datasets (Alamo, Roman Forum, Cornell), this must be done by
   matching each image against its nearest neighbor image using the Bag-of-Words
   image retrieval system of COLMAP.

     1. Exhaustive matching:
        First, make sure that all keypoints and descriptors exist. Then,
        run the corresponding section in the ``scripts/pipeline.m`` script.
        It is strongly recommended that you run this step on a machine with
        a CUDA-enabled GPU to speedup the matching process. Note that this
        step can take a significant amount of time. For example, the largest
        dataset for exhaustive matching (Madrid Metropolis) takes around
        16 hours to match on a single NVIDIA Titan X GPU. It is therefore
        recommended to check whether everything works on one of the smaller
        datasets before running the bigger datasets.
     2. Nearest neighbor matching: TODO

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

6. **Import the features and matches into COLMAP:**

   Run the Python script ``scripts/colmap_import.py``:

       python scripts/colmap_import.py --dataset_path path/to/Fountain

   You can now verify the features and matches using COLMAP by opening the
   COLMAP GUI and clicking ``Processing > Database management``. By selecting
   an image and clicking ``Show image`` you can see the detected keypoints.
   By clicking ``Show matches`` you can see the feature matches for each image.

   At this point, the feature matches are not geometrically verified, which is
   why there are no inlier matches in the database. To verify the matches,
   you must run the COLMAP ``matches_importer`` executable:

       ./matches_importer \
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

7. **Run the sparse reconstruction:**

    1. From the command-line:

           ./mapper \
               --database_path path/to/Fountain/database.db \
               --image_path path/to/Fountain/images \
               --export_path path/to/Fountain/sparse

    2. From the GUI:
       Open the COLMAP GUI, click ``File > New project``, ``Open`` the
       ``path/to/Fountain/database.db`` database file and image path.
       Next, click ``Reconstruction > Start reconstruction``.
