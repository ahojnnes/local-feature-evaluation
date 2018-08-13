import os
import cv2
import time
import argparse
import numpy as np


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset_path", required=True,
                        help="Path to the dataset, e.g., path/to/Fountain")
    args = parser.parse_args()
    return args


def read_matrix(path, dtype):
    with open(path, "rb") as fid:
        shape = np.fromfile(fid, count=2, dtype=np.int32)
        matrix = np.fromfile(fid, count=shape[0] * shape[1], dtype=dtype)
    return matrix.reshape(shape)


def write_matrix(path, matrix):
    with open(path, "wb") as fid:
        shape = np.array(matrix.shape, dtype=np.int32)
        shape.tofile(fid)
        matrix.tofile(fid)


def main():
    args = parse_args()

    if not os.path.exists(os.path.join(args.dataset_path, "descriptors")):
        os.makedirs(os.path.join(args.dataset_path, "descriptors"))

    convopt = cv2.xfeatures2d_VGG.create(scale_factor=6.75)

    image_names = os.listdir(os.path.join(args.dataset_path, "images"))

    for i, image_name in enumerate(image_names):

        keypoints_path = os.path.join(args.dataset_path, "keypoints",
                                      image_name + ".bin")
        if not os.path.exists(keypoints_path):
            continue

        print("Computing features for {} [{}/{}]".format(
              image_name, i + 1, len(image_names)), end="")

        start_time = time.time()

        descriptors_path = os.path.join(args.dataset_path, "descriptors",
                                        image_name + ".bin")
        if os.path.exists(descriptors_path):
            print(" -> skipping, already exist")
            continue

        image = cv2.imread(os.path.join(args.dataset_path,
                                        "images", image_name),
                           cv2.IMREAD_GRAYSCALE)

        opencv_keypoints = []
        for keypoint in read_matrix(keypoints_path, np.float32):
            opencv_keypoint = cv2.KeyPoint()
            opencv_keypoint.pt = (keypoint[0], keypoint[1])
            opencv_keypoint.size = keypoint[2]
            opencv_keypoint.angle = keypoint[3]
            opencv_keypoints.append(opencv_keypoint)

        descriptors = convopt.compute(image, opencv_keypoints)

        if descriptors is None:
            descriptors = np.zeros((0, 120), dtype=np.float32)

        write_matrix(descriptors_path, descriptors.astype(np.float32))

        print(" in {:.3f}s".format(time.time() - start_time))


if __name__ == "__main__":
    main()
