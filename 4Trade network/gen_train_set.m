function Y = gen_train_set()
% ============================================================
%  Purpose:
%  Generate a training dataset by simulating one-step propagation
%  on a trade network under varying levels of random directed
%   weight reduction.
%
%  INPUT:
%    • Required files (same folder):
%        T.mat        → 213×213 transition matrix
%        X_obs.mat    → Using only the baseline state 
%        ratios.mat   →  Weight reduction ratios
%
%  OUTPUT:
%    • train_set.mat → 3D tensor (nTrials × nRatios × N)
%        - Simulated propagation results under  weight loss
clc;
fprintf('\n=== Generating training set (weight perturbation) ===\n');
nTrials      = 1000;               
outFile      = 'train_set.mat';  

%% ------------ Default settings ------------
Tfile        = 'T.mat';           load(Tfile, 'T');                
activityFile = 'X_obs.mat';       load(activityFile, 'X_obs');    
ratioFile    = 'ratios.mat';      load(ratioFile, 'ratios'); 
weightRatios = ratios(:,1);         
nRatios      = size(ratios,1);

% ------------ Basic sizes & baseline ------------
T_base = double(T);                 %  transition matrix
N = size(T_base, 1);
% Pre-extract nonzero structure ONCE (topology fixed)
[i0, j0, v0] = find(T_base);
baseSum = sum(v0);

x0 = double(X_obs(1, :));           % baseline state (1×N)

% ------------ Output tensor ------------
Y = zeros(nTrials, N, nRatios, 'double');

% ------------ Main loop over ratios ------------
parfor r = 1:nRatios
    p = weightRatios(r);       
    alpha = 1 - p;

    fprintf('→ Ratio %3d / %3d | p = %.3f\n', ...
        r, nRatios, p);

    localY = zeros(nTrials, N);

    for t = 1:nTrials
        if alpha < 0.5
            perturbation = 2 * alpha * rand(size(v0));
            v = perturbation .* v0;
        else
            perturbation = (2 - 2 * alpha) * rand(size(v0));
            v = v0 - perturbation .* v0;
        end

        A_scaled = sparse(i0, j0, v, N, N);

        % ===== One-step propagation =====
        localY(t, :) = x0 * A_scaled;
    end

    Y(:, :, r) = localY;
end

Y = permute(Y, [1 3 2]);           % Convert to (nTrials × nRatios × N)


save(outFile, 'Y', '-v7.3');       % Save result (large file support)

end