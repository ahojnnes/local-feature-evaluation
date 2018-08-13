% Approximate matching pipeline using Bag-of-Words as a nearest neighbor metric.

command = [fullfile(COLMAP_PATH, 'src/tools/vocab_tree_retriever_float') ...
           ' --database_path ' DATABASE_PATH ...
           ' --descriptor_path ' DESCRIPTOR_PATH ...
           ' --vocab_tree_path ' VOCAB_TREE_PATH];
fprintf('Running command: %s\n', command);

% Note that if this command fails to execute here, you can simply run the
% command manually from the shell as well.
[status, output] = system(command);
assert(status == 0, 'Image retrieval failed, run the above command manually.');

retrieval_result_path = fullfile(DATASET_PATH, 'retrieval.txt')
fid = fopen(retrieval_result_path);
fprintf(fid, output);
fclose(fid);

fid = fopen(fullfile(DATASET_PATH, 'retrieval.txt'));

image_name_to_idx = containers.Map('KeyType', 'char', 'ValueType', 'int32');
for i = 1:num_images
    image_name_to_idx(image_names{i}) = i;
end

descriptors = containers.Map('KeyType', 'int32', 'ValueType', 'any');

num_matched_images = 0;

tline = fgets(fid);
while ischar(tline)
    if strcmp(tline(1:8), 'Querying')
        query_results = strsplit(tline(20:end), ' [');
        query_image_idx = image_name_to_idx(query_results{1});

        retrieved_image_idxs = [];

        tline = fgets(fid);
        while ischar(tline) && ~strcmp(tline(1:8), 'Querying')
            retrieval_results = strsplit(tline, ',');
            retrieved_image_name = retrieval_results{2};
            retrieved_image_name = retrieved_image_name(13:end);
            retrieved_image_idxs = [retrieved_image_idxs, ...
                                    image_name_to_idx(retrieved_image_name)];
            tline = fgets(fid);
        end

        num_matched_images = num_matched_images + 1;

        fprintf('Matching %s against %d images [%d/%d]', ...
                image_names{query_image_idx}, length(retrieved_image_idxs), ...
                num_matched_images, num_images);

        tic;

        % Read the descriptors for current query image.
        new_descriptors = containers.Map('KeyType', 'int32', ...
                                         'ValueType', 'any');
        for idx = [query_image_idx, retrieved_image_idxs]
            if descriptors.isKey(idx)
                new_descriptors(idx) = descriptors(idx);
                continue;
            end
            image_descriptors = single(read_descriptors(descriptor_paths{idx}));
            if MATCH_GPU
                new_descriptors(idx) = gpuArray(image_descriptors);
            else
                new_descriptors(idx) = image_descriptors;
            end
        end
        descriptors = new_descriptors;

        % Match the descriptors for current query image.
        for retrieved_image_idx = retrieved_image_idxs
            % Avoid self-matching.
            if query_image_idx == retrieved_image_idx
                continue;
            end

            % Order the indices to avoid duplicate pairs.
            if query_image_idx < retrieved_image_idx
                oidx1 = query_image_idx;
                oidx2 = retrieved_image_idx;
            else
                oidx1 = retrieved_image_idx;
                oidx2 = query_image_idx;
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

        fprintf(' in %.3fs\n', toc);
    else
        tline = fgets(fid);
    end
end

fclose(fid);

% Clear the GPU memory.
clear descriptors;
clear matches;
