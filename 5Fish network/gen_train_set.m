function Y = gen_train_set()
% ============================================================
%  Purpose:
%  Generate a training dataset by simulating random node removal on a fish ecosystem network, 
%  based on a fixed baseline observation.
%
%  INPUT:
%    • Required files (same folder):
%        X_obs.mat    → Using only the baseline state 
%        ratios.mat   → node loss
%
%  OUTPUT:
%    • train_set.mat → 3D tensor (nTrials × nRatios × N)
%        - Simulated node loss
% 
clc;
fprintf('\n=== Generating fish training set (state decline) ===\n');
nTrials      = 100000;               
outFile      = 'train_set.mat';  

%% ------------ Default settings ------------
Tfile        = 'T.mat';           load(Tfile, 'T');                
activityFile = 'X_obs.mat';       load(activityFile, 'X_obs');    
ratioFile    = 'ratios.mat';      load(ratioFile, 'ratios');   
% --- Extract variables ---
nodeRatios   = ratios(:,1);          % Node loss
nRatios      = size(ratios,1);

% ------------ Basic sizes & baseline ------------
T_base = double(T);                 %  transition matrix
N = size(T_base, 1);
x0 = double(X_obs(1,:));         % Baseline node state (first observation)

%% ------------ Parallel perturbation loop ------------
Y = zeros(nTrials, N, nRatios,'double');
parfor r = 1:nRatios
    p  = nodeRatios(r);    % node loss
   
    fprintf('→ Ratio %3d / %3d | p: %.3f\n', ...
        r, nRatios, p);

    localY = zeros(nTrials, N);
   for t = 1:nTrials
    % --- 1) random node removal ---
    nRem   = round(p * N);
    remIdx = randperm(N, nRem);

    % --- 2) build perturbed transition matrix ---
    Tpert = T;                     % copy baseline T
    Tpert(remIdx,:) = 0;           % remove outgoing edges
    Tpert(:,remIdx) = 0;           % remove incoming edges

    % --- 3) propagate ---
    localY(t,:) = x0 * Tpert;
         
   end

    Y(:, :, r) = localY;
end

Y = permute(Y, [1 3 2]);           % Convert to (nTrials × nRatios × N)


%% ------------ Post-processing and save ------------
for t = 1:nTrials
    Y(t,1,:) = reshape(X_obs(1,:), [1 1 N]);  % Include baseline activity
end

save(outFile, 'Y', '-v7.3');        
end






