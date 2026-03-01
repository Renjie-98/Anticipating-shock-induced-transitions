function X_p = compute_X_p_slice()
% ============================================================
%  Purpose:
%  Predict perturbed states X_p from observed baseline data X_obs
%  using precomputed slice maps (R_p_slice) under:
%
%  INPUT:
%    • X_obs.mat      → X_obs (numPerturb × numNodes)
%    • R_p_slices/    → R_p_slice_XXX.mat (contains R_p_slice)
%
%  OUTPUT:
%    • X_p.mat → X_p (numPerturb × numNodes, double)
% ============================================================

%% --- Load observed data ---
load('X_obs.mat', 'X_obs');
[numPerturb, numNodes] = size(X_obs);

load('T.mat', 'T');
X_obs= X_obs * T;
X0 = X_obs(1,:);    % Baseline state (use day 1 / first row)                     

%% --- Collect slice files ---
sliceDir = 'R_p_slices';
files = sort({dir(fullfile(sliceDir,'R_p_slice_*.mat')).name});

%% --- Sequential prediction  ---
X_p = zeros(numPerturb-1, numNodes, 'double');
for p = 1:numPerturb-1
    Rp = load(fullfile(sliceDir, files{p}), 'R_p_slice').R_p_slice;               
    X_p(p,:) = X0 * Rp.';            
end

X_p = [X_obs(1,:); X_p]; 

save('X_p.mat', 'X_p', '-v7.3');

end
