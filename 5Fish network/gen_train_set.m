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
%        ratios.mat   → State decline ratios
%
%  OUTPUT:
%    • train_set.mat → 3D tensor (nTrials × nRatios × N)
%        - Simulated node states under 
%           state reduction
% ============================================================
clc;
fprintf('\n=== Generating fish training set (state decline) ===\n');

nTrials      = 1000;               
outFile      = 'train_set.mat';  

%% ------------ Default settings ------------
activityFile = 'X_obs.mat';       load(activityFile, 'X_obs');    
ratioFile    = 'ratios.mat';      load(ratioFile, 'ratios');   
% --- Extract variables ---
stateRatios = ratios(:,1);          % State reduction ratios
nRatios     = size(ratios,1);

%% ------------ Initialize baseline state ------------
x0 = double(X_obs(1,:));         % Baseline node state (first observation)
N  = size(X_obs,2);              % Number of nodes

%% ------------ Parallel perturbation loop ------------
Y = zeros(nTrials, nRatios, N, 'double');
parfor r = 1:nRatios
    stateLoss  = stateRatios(r);    % Fractional reduction in overall node states
   fprintf('→ Ratio %3d / %3d | State loss: %.3f\n', ...
        r, nRatios, stateLoss);
    localY = zeros(nTrials, N);
    for t = 1:nTrials

        % State reduction ---
        scaleFactor = 2 * (1 - stateLoss) * rand(1, N);  % 1×N vector
        xPert = x0 .* scaleFactor;
        % Record perturbed node states
        localY(t,:) = xPert;
    end

    Y(:,r,:) = localY;               
end

%% ------------ Post-processing and save ------------
for t = 1:nTrials
    Y(t,1,:) = reshape(X_obs(1,:), [1 1 N]);  % Include baseline activity
end

save(outFile, 'Y', '-v7.3');        
end

