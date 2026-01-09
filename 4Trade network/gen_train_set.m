function Y = gen_train_set()
% ============================================================
%  Purpose:
%  Generate a training dataset by simulating one-step propagation
%  on a trade network under varying levels of random directed
%  link removal and weight reduction.
%
%  INPUT:
%    • Required files (same folder):
%        T.mat        → 213×213 transition matrix
%        X_obs.mat    → Using only the baseline state 
%        ratios.mat   → link removal ratios and Weight reduction ratios
%
%  OUTPUT:
%    • train_set.mat → 3D tensor (nTrials × nRatios × N)
%        - Simulated propagation results under combined link losses and weight loss
clc;
fprintf('\n=== Generating training set (link + weight perturbation) ===\n');
nTrials      = 1000;               
outFile      = 'train_set.mat';  

%% ------------ Default settings ------------
Tfile        = 'T.mat';           load(Tfile, 'T');                
activityFile = 'X_obs.mat';    load(activityFile, 'X_obs');    
ratioFile    = 'ratios.mat';      load(ratioFile, 'ratios');   
linkRatios   = ratios(:,1);         % Link loss ratios
weightRatios = ratios(:,2);         % Weight loss ratios
nRatios      = size(ratios,1);

%% ------------ Initialize baseline state ------------
x0 = double(X_obs(1,:));         % Baseline state (first year 2008)
N  = size(T,1);

%% ------------ Identify existing links ------------
[rowIdx, colIdx, val] = find(T);    % Nonzero elements (active links)
nEdges = numel(rowIdx);

%% ------------ Parallel computation loop ------------
Y = zeros(nTrials, N, nRatios, 'double');
parfor r = 1:nRatios
    linkLoss   = linkRatios(r);     % Current link loss ratio
    weightLoss = weightRatios(r);   % Current weight loss ratio
    fprintf('→ Computing ratio %3d / %3d | Link loss: %.3f | Weight loss: %.3f\n', ...
        r, nRatios, linkLoss, weightLoss);

    m = floor(linkLoss * nEdges);   % Number of links to remove
    localY = zeros(nTrials, N);
    for t = 1:nTrials
        % --- Step 1: link removal ---
        sel = randperm(nEdges, m);    % Randomly select m links to remove
        Tpert = T;                    % Copy transition matrix
        Tpert(sub2ind(size(Tpert), rowIdx(sel), colIdx(sel))) = 0; % Remove links

        % --- Step 2: Weight reducation ---
        currentSum = sum(Tpert(:));
        targetSum  = (1 - weightLoss) * sum(T(:));
        scaleFactor = targetSum / currentSum;
        Tpert = Tpert * scaleFactor;
        

        localY(t,:) = x0 * Tpert;    % One-step propagation
    end
    Y(:,:,r) = localY;               % Assign results to tensor
end
Y = permute(Y, [1 3 2]);           % Convert to (nTrials × nRatios × N)

%% ------------ Post-processing and save ------------
for t = 1:nTrials
    Y(t,1,:) = reshape(X_obs(1,:), [1 1 N]);  % Include baseline activity
end

save(outFile, 'Y', '-v7.3');       % Save result (large file support)
fprintf('\n✓ Done! Training set saved to %s\n', outFile);

end