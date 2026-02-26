function Y = gen_train_set()
% ============================================================
%  Purpose:
%  Generate a training dataset by simulating one-step propagation on a
%  flight network under different levels of random directed link removal.
%
%  INPUT:
%    • Required files (same folder):
%        T.mat        → Transition matrix
%        X_obs.mat    → Using only the baseline state 
%        ratios.mat   → link loss ratios
%
%  OUTPUT:
%    • Training_set.mat → 3D tensor (nTrials × nRatios × N)
%        - Simulated propagation results under varying link losses
%
clc;
fprintf('\n=== Generating training set (Y) in parallel ===\n');
nTrials      = 1000;                
outFile      = 'train_set.mat'; 
%% ------------ Default settings ------------
Tfile        = 'T.mat';           load(Tfile, 'T');                
activityFile = 'X_obs.mat';    load(activityFile, 'X_obs');    
ratioFile    = 'ratios.mat';      load(ratioFile, 'ratios');      
linkRatios = ratios(:);           
nRatios    = numel(linkRatios);

%% ------------ Initialize baseline state ------------
x0 = double(X_obs(1,:));        % Baseline state (day 1)
N  = size(T,1);

%% ------------ Identify existing links ------------
[rowIdx, colIdx] = find(T);        % Indices of existing links
nEdges = numel(rowIdx);            % Total number of links

%% ------------ Parallel computation loop ------------
Y = zeros(nTrials, N, nRatios, 'double');
parfor r = 1:nRatios
    fprintf('→ Computing ratio %3d / %3d (%.4f)\n', r, nRatios, linkRatios(r));
   
    m = floor(linkRatios(r) * nEdges);     % Number of links to remove
    localY = zeros(nTrials, N);
    for t = 1:nTrials
        sel = randperm(nEdges, m);         % Randomly select m links to remove
        Tpert = T;                         % Copy transition matrix
        Tpert(sub2ind(size(Tpert), rowIdx(sel), colIdx(sel))) = 0; % Remove links
        localY(t,:) = x0 * Tpert;          % One-step propagation
    end
    Y(:,:,r) = localY;                     % Assign results to tensor
end
Y = permute(Y, [1 3 2]);           % Convert to (nTrials × nRatios × N)

%% ------------ Post-processing and save ------------
for t = 1:nTrials
    Y(t,1,:) = reshape(X_obs(1,:), [1 1 N]);  % Include baseline activity
end

save(outFile, 'Y', '-v7.3');       % Save result (large file support)
fprintf('\n✓ Done! Training set saved to %s\n', outFile);

end
