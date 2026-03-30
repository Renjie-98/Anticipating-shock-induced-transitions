function compute_Xp()
% COMPUTE_XP
% Predict three perturbed states using precomputed linear maps:
%   X_p_tstar
%   X_p_tminus
%   X_p_tplus

    %% --- 1. Load testing data from workspace ---
    X_test_tstar  = evalin('base', 'X_test_tstar');
    X_test_tminus = evalin('base', 'X_test_tminus');
    X_test_tplus  = evalin('base', 'X_test_tplus');

    % remove the 2nd slice: unperturbed response
    X_test_tstar(:,2,:)  = [];
    X_test_tminus(:,2,:) = [];
    X_test_tplus(:,2,:)  = [];

    % reference states
    X0 = squeeze(X_test_tstar(:,1,:));   % [E x N]

    [numExps, numPerturb, numNodes] = size(X_test_tstar);

    %% --- 2. Load learned response maps ---
    baseFolder = 'compute data/6.Population_Little Rock Lake_perturbation_type3';
    load(fullfile(baseFolder, 'R_p.mat'), ...
        'R_p_tstar', 'R_p_tminus', 'R_p_tplus');

    %% --- 3. Predict X_p at t* ---
    X_p_tstar = zeros(numExps, numPerturb, numNodes);
    for p = 1:numPerturb
        Rp_current = R_p_tstar(:,:,p);       % [N x N]
        Xp_current = Rp_current * X0.';      % [N x E]
        X_p_tstar(:,p,:) = Xp_current.';     % [E x N]
    end

    %% --- 4. Predict X_p at t- ---
    X_p_tminus = zeros(numExps, numPerturb, numNodes);
    for p = 1:numPerturb
        Rp_current = R_p_tminus(:,:,p);      % [N x N]
        Xp_current = Rp_current * X0.';      % [N x E]
        X_p_tminus(:,p,:) = Xp_current.';    % [E x N]
    end

    %% --- 5. Predict X_p at t+ ---
    X_p_tplus = zeros(numExps, numPerturb, numNodes);
    for p = 1:numPerturb
        Rp_current = R_p_tplus(:,:,p);       % [N x N]
        Xp_current = Rp_current * X0.';      % [N x E]
        X_p_tplus(:,p,:) = Xp_current.';     % [E x N]
    end

    %% --- 6. Output ---
    assignin('base', 'X_p_tstar', X_p_tstar);
    assignin('base', 'X_p_tminus', X_p_tminus);
    assignin('base', 'X_p_tplus', X_p_tplus);

    save(fullfile(baseFolder, 'X_p.mat'), ...
        'X_p_tstar', 'X_p_tminus', 'X_p_tplus', '-v7.3');

end