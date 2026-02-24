function X_p = compute_X_p_slice()
% ============================================================
%  Purpose:
%  Predict perturbed states X_p from observed baseline data X_obs
%  using precomputed slice maps (R_p_slice, b_p_slice) under:
%
%  INPUT:
%    • X_obs.mat      → X_obs (numPerturb × numNodes)
%    • R_p_slices/    → R_p_slice_XXX.mat (contains R_p_slice, b_p_slice)
%
%  OUTPUT:
%    • X_p.mat → X_p (numPerturb × numNodes, double)
% ============================================================

%% --- Load observed data ---
S = load('X_obs.mat', 'X_obs');
X_obs = double(S.X_obs);                  % numPerturb × numNodes
[numPerturb, numNodes] = size(X_obs);
X0 = X_obs(1,:);    % Baseline state (use day 1 / first row)                     

%% --- Collect slice files ---
sliceDir = 'R_p_slices';
fileInfo = dir(fullfile(sliceDir, 'R_p_slice_*.mat'));
files = sort({fileInfo.name});            % expects 001, 002, ...

%% --- Sequential prediction (with bias) ---
X_p = zeros(numPerturb, numNodes, 'double');
for p = 1:numPerturb
    Sp = load(fullfile(sliceDir, files{p}), 'R_p_slice');
    Rp = Sp.R_p_slice;                   
    X_p(p,:) = X0 * Rp ;            

    if mod(p,25)==0 || p==1 || p==numPerturb
        fprintf('→ Finished slice %3d / %3d (%s)\n', p, numPerturb, files{p});
    end
end

%% --- Save ---
save('X_p.mat', 'X_p', '-v7.3');

end
