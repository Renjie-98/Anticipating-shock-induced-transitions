function compute_Xp()
% COMPUTE_XP
% Predict perturbed states X_p using precomputed linear maps R_p.
% For each perturbation p:
%   X_p ≈ R_p X_0 

    %% --- 1. Load testing data ---
    dataVarName = input('Enter the testing data in the workspace: ', 's');
    data3D = evalin('base', dataVarName);      % [E x P x N]
    %% ---the added (begin) ---  
    % We regenerated the testing data since the initial states were not saved. 
    % The first step represents the unperturbed initial state, 
    % the second the unperturbed steady state, and the remaining steps the perturbed steady states. 
    % We remove the second step here.
    data3D(:,2,:) = []; 
    %% ---the added (end) ---
    [numExps, numPerturb, numNodes] = size(data3D);
    X0 = squeeze(data3D(:,1,:));               % reference states [E x N]

    %% --- 2. Load learned response maps ---
    load(fullfile('compute data/2.Epidemics (SIS)_MIT Reality Mining_perturbation_type2-0.6', ...
                  'R_p.mat'), 'R_p');

    %% --- 3. Predict X_p ---
    X_p = zeros(numExps, numPerturb, numNodes);
    for p = 1:numPerturb
        Rp_current = R_p(:,:,p);               % response matrix [N x N]
        Xp_current = Rp_current * X0.';        % predicted states [N x E]
        X_p(:,p,:) = Xp_current.';             % store as [E x N]
    end

    %% --- 4. Output ---
    assignin('base', 'X_p', X_p);
    baseFolder = 'compute data/2.Epidemics (SIS)_MIT Reality Mining_perturbation_type2-0.6';
    save(fullfile(baseFolder,'X_p.mat'),'X_p','-v7.3');

end   