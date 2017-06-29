% Exhaustive matching pipeline.

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

% Clear the GPU memory.
clear descriptors;
clear matches;
