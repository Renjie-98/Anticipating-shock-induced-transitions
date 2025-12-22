function X_p = compute_Xp()
% COMPUTE_XP
% Predict perturbed states X_p using precomputed linear maps R_p and offsets b_p.
% For each perturbation p:
%   X_p ≈ R_p X_0 + b_p

    %% --- 1. Load testing data ---
    dataVarName = input('Enter the testing data in the workspace: ', 's');
    data3D = evalin('base', dataVarName);      % [E x P x N]
    [numExps, numPerturb, numNodes] = size(data3D);
    X0 = squeeze(data3D(:,1,:));               % reference states [E x N]

    %% --- 2. Load learned response maps ---
    load(fullfile('compute data/1.Mutualistic_Coral Reefs_perturbation_type1', ...
                  'R_p_b_p.mat'), 'R_p', 'b_p');

    %% --- 3. Predict X_p ---
    X_p = zeros(numExps, numPerturb, numNodes);
    for p = 1:numPerturb
        Rp_current = R_p(:,:,p);               % response matrix [N x N]
        bp_current = b_p(:,p);                 % offset vector [N x 1]
        Xp_current = Rp_current * X0.' + bp_current;  % predicted states [N x E]
        X_p(:,p,:) = Xp_current.';             % store as [E x N]
    end

    %% --- 4. Output ---
    assignin('base', 'X_p', X_p);
    save('X_p.mat', 'X_p');
end
