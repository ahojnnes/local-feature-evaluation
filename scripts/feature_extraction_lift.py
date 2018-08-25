import os
import h5py
import argparse
import numpy as np


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset_path", required=True,
                        help="Path to the dataset, e.g., path/to/Fountain")
    args = parser.parse_args()
    return args


def write_matrix(path, matrix):
    with open(path, "wb") as fid:
        shape = np.array(matrix.shape, dtype=np.int32)
        shape.tofile(fid)
        matrix.tofile(fid)


def main():
    args = parse_args()

    if not os.path.exists(os.path.join(args.dataset_path, "descriptors")):
        os.makedirs(os.path.join(args.dataset_path, "descriptors"))

    image_names = os.listdir(os.path.join(args.dataset_path, "images"))

    for i, image_name in enumerate(image_names):
        print("Importing features for {} [{}/{}]".format(
              image_name, i + 1, len(image_names)))

        data = h5py.File(os.path.join(
            args.dataset_path, "lift", image_name + "_desc.h5"), "r")

        keypoints = np.array(data["keypoints"])[:, :4].astype(np.float32)
        descriptors = np.array(data["descriptors"]).astype(np.float32)

        keypoints_path = os.path.join(args.dataset_path, "keypoints",
                                      image_name + ".bin")
        descriptors_path = os.path.join(args.dataset_path, "descriptors",
                                        image_name + ".bin")

        write_matrix(keypoints_path, keypoints)
        write_matrix(descriptors_path, descriptors)


if __name__ == "__main__":
    main()
