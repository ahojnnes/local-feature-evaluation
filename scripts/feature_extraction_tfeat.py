import os
import sys
import cv2
import math
import time
import argparse
import numpy as np
import h5py

import torchvision as tv
import phototour
import torch
from tqdm import tqdm
import torch.nn as nn
import tfeat_model
import torch.optim as optim
import torch.nn.functional as F
import torch.backends.cudnn as cudnn


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dataset_path", required=True,
                        help="Path to the dataset, e.g., path/to/Fountain")
    parser.add_argument("--model_path", default="tfeat-liberty.params")
    parser.add_argument("--batch_size", type=int, default=512)
    args = parser.parse_args()
    return args


def write_matrix(path, matrix):
    with open(path, "wb") as fid:
        shape = np.array(matrix.shape, dtype=np.int32)
        shape.tofile(fid)
        matrix.tofile(fid)


def main():
    args = parse_args()

    tfeat = tfeat_model.TNet()
    tfeat.load_state_dict(torch.load(args.model_path))
    tfeat.cuda()
    tfeat.eval()

    if not os.path.exists(os.path.join(args.dataset_path, "descriptors")):
        os.makedirs(os.path.join(args.dataset_path, "descriptors"))

    image_names = os.listdir(os.path.join(args.dataset_path, "images"))

    for i, image_name in enumerate(image_names):

        patches_path = os.path.join(args.dataset_path, "descriptors",
                                    image_name + ".bin.patches.mat")
        if not os.path.exists(patches_path):
            continue

        print("Computing features for {} [{}/{}]".format(
              image_name, i + 1, len(image_names)), end="")

        start_time = time.time()

        descriptors_path = os.path.join(args.dataset_path, "descriptors",
                                        image_name + ".bin")
        if os.path.exists(descriptors_path):
            print(" -> skipping, already exist")
            continue

        with h5py.File(patches_path, 'r') as patches_file:
            patches31 = np.array(patches_file["patches"]).T

        if patches31.ndim != 3:
            print(" -> skipping, invalid input")
            write_matrix(descriptors_path, np.zeros((0, 128), dtype=np.float32))
            continue

        patches = np.empty((patches31.shape[0], 32, 32), dtype=np.float32)
        patches[:, :31, :31] = patches31
        patches[:, 31, :31] = patches31[:, 30, :]
        patches[:, :31, 31] = patches31[:, :, 30]
        patches[:, 31, 31] = patches31[:, 30, 30]

        descriptors = []
        for i in range(0, patches.shape[0], args.batch_size):
            patches_batch = \
                patches[i:min(i + args.batch_size, patches.shape[0])]
            patches_batch = \
                torch.from_numpy(patches_batch[:, None]).float().cuda()
            descriptors.append(tfeat(patches_batch).detach().cpu().numpy())

        if len(descriptors) == 0:
            descriptors = np.zeros((0, 128), dtype=np.float32)
        else:
            descriptors = np.concatenate(descriptors)

        write_matrix(descriptors_path, descriptors)

        print(" in {:.3f}s".format(time.time() - start_time))


if __name__ == "__main__":
    main()
