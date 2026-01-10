function Y = gen_train_set()
%  Purpose:
%  Generate a training dataset by simulating combined
%  random node removal and global state reduction
%  on a fish ecosystem network, based on a fixed
%  baseline observation.
%
%  INPUT:
%    • Required files (same folder):
%        X_obs.mat    → Baseline node state (first observation)
%        ratios.mat   → Node removal ratios and state decline ratios
%
%  OUTPUT:
%    • train_set.mat → 3D tensor (nTrials × nRatios × N)
%        - Simulated node states under combined
%          node loss and state reduction
% ============================================================
clc;
fprintf('\n=== Generating fish training set (node removal + state decline) ===\n');

nTrials      = 1000;               
outFile      = 'train_set.mat';  

%% ------------ Default settings ------------
activityFile = 'X_obs.mat';    load(activityFile, 'X_obs');    
ratioFile    = 'ratios.mat';      load(ratioFile, 'ratios');   
% --- Extract variables ---
nodeRatios  = ratios(:,1);          % Node removal ratios
stateRatios = ratios(:,2);          % State reduction ratios
nRatios     = size(ratios,1);

%% ------------ Initialize baseline state ------------
x0 = double(X_obs(1,:));         % Baseline node state (first observation)
N  = size(X_obs,2);              % Number of nodes

%% ------------ Parallel perturbation loop ------------
Y = zeros(nTrials, nRatios, N, 'double');
parfor r = 1:nRatios
    nodeLoss   = nodeRatios(r);     % Fraction of nodes removed
    stateLoss  = stateRatios(r);    % Fractional reduction in overall node states
    fprintf('→ Ratio %3d / %3d | Node removal: %.3f | State decline: %.3f\n', ...
        r, nRatios, nodeLoss, stateLoss);

    m = floor(nodeLoss * N);        % Number of nodes to remove
    localY = zeros(nTrials, N);
    for t = 1:nTrials
        % --- Step 1: node removal ---
        xPert = x0;
        remIdx = randperm(N, m);
        xPert(remIdx) = 0;
        % --- Step 2: State reduction ---
        xPert = xPert * (1 - stateLoss);
        % Record perturbed node states
        localY(t,:) = xPert;
    end

    Y(:,r,:) = localY;               
end

%% ------------ Post-processing and save ------------
for t = 1:nTrials
    Y(t,1,:) = reshape(X_obs(1,:), [1 1 N]);  % Include baseline activity
end

save(outFile, 'Y', '-v7.3');        % Save with large-file support
fprintf('\n✓ Done! Training set saved to %s\n', outFile);

end
