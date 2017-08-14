# Import the features and matches into a COLMAP database.
#
# Copyright 2017: Johannes L. Schoenberger <jsch at inf.ethz.ch>

from __future__ import print_function, division

import os
import glob
import argparse
import sqlite3
import subprocess
import multiprocessing

import numpy as np


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset_path", required=True,
                        help="Path to the dataset, e.g., path/to/Fountain")
    parser.add_argument("--colmap_path", required=True,
                        help="Path to the COLMAP executable folder, e.g., "
                             "path/to/colmap/build/src/exe")
    args = parser.parse_args()
    return args


def image_ids_to_pair_id(image_id1, image_id2):
    if image_id1 > image_id2:
        return 2147483647 * image_id2 + image_id1
    else:
        return 2147483647 * image_id1 + image_id2


def read_matrix(path, dtype):
    with open(path, "rb") as fid:
        shape = np.fromfile(fid, count=2, dtype=np.int32)
        matrix = np.fromfile(fid, count=shape[0] * shape[1], dtype=dtype)
    return matrix.reshape(shape)


def import_matches(args):
    connection = sqlite3.connect(os.path.join(args.dataset_path, "database.db"))
    cursor = connection.cursor()

    cursor.execute("DELETE FROM keypoints;")
    cursor.execute("DELETE FROM descriptors;")
    cursor.execute("DELETE FROM matches;")
    cursor.execute("DELETE FROM inlier_matches;")
    connection.commit()

    images = {}
    cursor.execute("SELECT name, image_id FROM images;")
    for row in cursor:
        images[row[0]] = row[1]

    for image_name, image_id in images.items():
        print("Importing features for", image_name)
        keypoint_path = os.path.join(args.dataset_path, "keypoints",
                                     image_name + ".bin")
        keypoints = read_matrix(keypoint_path, np.float32)
        descriptor_path = os.path.join(args.dataset_path, "descriptors",
                                     image_name + ".bin")
        descriptors = read_matrix(descriptor_path, np.float32)
        assert keypoints.shape[1] == 4
        assert keypoints.shape[0] == descriptors.shape[0]
        cursor.execute("INSERT INTO keypoints(image_id, rows, cols, data) "
                       "VALUES(?, ?, ?, ?);",
                       (image_id, keypoints.shape[0], keypoints.shape[1],
                        memoryview(keypoints)))
        connection.commit()

    image_pairs = []
    for match_path in glob.glob(os.path.join(args.dataset_path,
                                             "matches/*---*.bin")):
        image_name1, image_name2 = \
            os.path.basename(match_path[:-4]).split("---")
        image_pairs.append((image_name1, image_name2))
        print("Importing matches for", image_name1, "---", image_name2)
        image_id1, image_id2 = images[image_name1], images[image_name2]
        image_pair_id = image_ids_to_pair_id(image_id1, image_id2)
        matches = read_matrix(match_path, np.uint32)
        assert matches.shape[1] == 2
        cursor.execute("INSERT INTO  matches(pair_id, rows, cols, data) "
                       "VALUES(?, ?, ?, ?);",
                       (image_pair_id, matches.shape[0], matches.shape[1],
                        memoryview(matches)))
        connection.commit()

    with open(os.path.join(args.dataset_path, "image-pairs.txt"), "w") as fid:
        for image_name1, image_name2 in image_pairs:
            fid.write("{} {}\n".format(image_name1, image_name2))

    cursor.close()
    connection.close()

    subprocess.call([os.path.join(args.colmap_path, "matches_importer"),
                     "--database_path",
                     os.path.join(args.dataset_path, "database.db"),
                     "--match_list_path",
                     os.path.join(args.dataset_path, "image-pairs.txt"),
                     "--match_type", "pairs"])

    connection = sqlite3.connect(os.path.join(args.dataset_path, "database.db"))
    cursor = connection.cursor()

    cursor.execute("SELECT count(*) FROM images;")
    num_images = next(cursor)[0]

    cursor.execute("SELECT count(*) FROM inlier_matches WHERE rows > 0;")
    num_inlier_pairs = next(cursor)[0]

    cursor.execute("SELECT sum(rows) FROM inlier_matches WHERE rows > 0;")
    num_inlier_matches = next(cursor)[0]

    cursor.close()
    connection.close()

    return dict(num_images=num_images,
                num_inlier_pairs=num_inlier_pairs,
                num_inlier_matches=num_inlier_matches)


def reconstruct(args):
    database_path = os.path.join(args.dataset_path, "database.db")
    image_path = os.path.join(args.dataset_path, "images")
    sparse_path = os.path.join(args.dataset_path, "sparse")
    dense_path = os.path.join(args.dataset_path, "dense")

    if not os.path.exists(sparse_path):
        os.makedirs(sparse_path)
    if not os.path.exists(dense_path):
        os.makedirs(dense_path)

    # Run the sparse reconstruction.

    subprocess.call([os.path.join(args.colmap_path, "mapper"),
                     "--database_path", database_path,
                     "--image_path", image_path,
                     "--export_path", sparse_path,
                     "--Mapper.num_threads",
                     str(min(multiprocessing.cpu_count(), 16))])

    # Find the largest reconstructed sparse model.

    models = os.listdir(sparse_path)
    if len(models) == 0:
        print("Warning: Could not reconstruct any model")
        return

    largest_model = None
    largest_model_num_images = 0
    for model in models:
        subprocess.call([os.path.join(args.colmap_path, "model_converter"),
                         "--input_path", os.path.join(sparse_path, model),
                         "--output_path", os.path.join(sparse_path, model),
                         "--output_type", "TXT"])
        with open(os.path.join(sparse_path, model, "cameras.txt"), "r") as fid:
            for line in fid:
                if line.startswith("# Number of cameras"):
                    num_images = int(line.split()[-1])
                    if num_images > largest_model_num_images:
                        largest_model = model
                        largest_model_num_images = num_images
                    break

    assert largest_model_num_images > 0

    # Run the dense reconstruction.

    largest_model_path = os.path.join(sparse_path, largest_model)
    workspace_path = os.path.join(dense_path, largest_model)
    if not os.path.exists(workspace_path):
        os.makedirs(workspace_path)

    subprocess.call([os.path.join(args.colmap_path, "image_undistorter"),
                     "--image_path", image_path,
                     "--input_path", largest_model_path,
                     "--output_path", workspace_path,
                     "--max_image_size", "1200"])

    subprocess.call([os.path.join(args.colmap_path, "dense_stereo"),
                     "--workspace_path", workspace_path,
                     "--DenseStereo.geom_consistency", "false"])

    subprocess.call([os.path.join(args.colmap_path, "dense_fuser"),
                     "--workspace_path", workspace_path,
                     "--input_type", "photometric",
                     "--output_path", os.path.join(workspace_path, "fused.ply"),
                     "--DenseFusion.min_num_pixels", "5"])

    stats = subprocess.check_output(
        [os.path.join(args.colmap_path, "model_analyzer"),
         "--path", largest_model_path])

    stats = stats.decode().split("\n")
    for stat in stats:
        if stat.startswith("Registered images"):
            num_reg_images = int(stat.split()[-1])
        elif stat.startswith("Points"):
            num_sparse_points = int(stat.split()[-1])
        elif stat.startswith("Observations"):
            num_observations = int(stat.split()[-1])
        elif stat.startswith("Mean track length"):
            mean_track_length = float(stat.split()[-1])
        elif stat.startswith("Mean observations per image"):
            num_observations_per_image = float(stat.split()[-1])
        elif stat.startswith("Mean reprojection error"):
            mean_reproj_error = float(stat.split()[-1][:-2])

    with open(os.path.join(workspace_path, "fused.ply"), "rb") as fid:
        line = fid.readline().decode()
        while line:
            if line.startswith("element vertex"):
                num_dense_points = int(line.split()[-1])
                break
            line = fid.readline().decode()

    return dict(num_reg_images=num_reg_images,
                num_sparse_points=num_sparse_points,
                num_observations=num_observations,
                mean_track_length=mean_track_length,
                num_observations_per_image=num_observations_per_image,
                mean_reproj_error=mean_reproj_error,
                num_dense_points=num_dense_points)


def main():
    args = parse_args()

    matching_stats = import_matches(args)
    reconstruction_stats = reconstruct(args)

    print()
    print(78 * "=")
    print("Raw statistics")
    print(78 * "=")
    print(matching_stats)
    print(reconstruction_stats)

    print()
    print(78 * "=")
    print("Formatted statistics")
    print(78 * "=")
    print(" | ".join(
            map(str, [os.path.basename(args.dataset_path),
                      "METHOD",
                      matching_stats["num_images"],
                      reconstruction_stats["num_reg_images"],
                      reconstruction_stats["num_sparse_points"],
                      reconstruction_stats["num_observations"],
                      reconstruction_stats["mean_track_length"],
                      reconstruction_stats["num_observations_per_image"],
                      reconstruction_stats["mean_reproj_error"],
                      reconstruction_stats["num_dense_points"],
                      "",
                      "",
                      "",
                      "",
                      matching_stats["num_inlier_pairs"],
                      matching_stats["num_inlier_matches"]])))


if __name__ == "__main__":
    main()
