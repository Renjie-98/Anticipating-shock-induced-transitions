function X_p = compute_Xp()
% COMPUTE_XP
% Predict perturbed states X_p using precomputed linear maps R_p and offsets b_p.
% For each perturbation p:
%   X_p ≈ R_p X_0 + b_p

    folderPath = fullfile('compute data', '1.Mutualistic_Coral Reefs_perturbation_type1');

    % 1) load testing data
    load(fullfile(folderPath, 'X_test.mat'), 'X_test');   % [E x P x N]
    [numExps, numPerturb, numNodes] = size(X_test);
    X0 = squeeze(X_test(:,1,:));   % [E x N]

    % 2) load response maps
    load(fullfile(folderPath, 'R_p_b_p.mat'), 'R_p', 'b_p');

    % 3) predict
    X_p = zeros(numExps, numPerturb, numNodes);
    for p = 1:numPerturb
        Xp = R_p(:,:,p) * X0.' + b_p(:,p);   % [N x E]
        X_p(:,p,:) = Xp.';                  % [E x N]
    end

    % 4) save
    assignin('base', 'X_p', X_p);
    save(fullfile(folderPath, 'X_p.mat'), 'X_p');
end

