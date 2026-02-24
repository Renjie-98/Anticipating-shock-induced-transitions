function compute_R_p_slice()
% ============================================================
%  Purpose:
%  Estimate linear response operators (R_p) from the training tensor Y
%
%  INPUT:
%    • train_set.mat → Y (numExps × numPerturb × numNodes)
%
%  OUTPUT (unchanged format: slice-by-slice files):
%    • Folder: R_p_slices
%        - R_p_slice_XXX.mat contains:
%            R_p_slice  (numNodes × numNodes)
% ============================================================

%% ------------ Load Y ------------
load('train_set.mat', 'Y');
[numExps, numPerturb, numNodes] = size(Y);

%% ------------ Compute covariance C00 ------------
X0  = squeeze(Y(:, 1, :));          % baseline across experiments
C00 = zeros(numNodes, numNodes, 'double');
for i = 1:numExps
    C00 = C00 + X0(i,:).' * X0(i,:);             
end
C00inv = pinv_trunc(C00 / numExps);

%% ------------ Create output folder (unchanged) ------------
outDir = 'R_p_slices';
mkdir(outDir);

%% ------------ Compute and save each R_p slice ------------
parfor p = 2:numPerturb
    fprintf('→ Computing and saving slice %3d / %3d of R_p ...\n', p, numPerturb);
    Xp  = squeeze(Y(:, p, :));
    Cp0 = zeros(numNodes, numNodes, 'double');
    for i = 1:numExps
        Cp0 = Cp0 + Xp(i,:).' * X0(i,:);
        %% 
    end
     R_p_slice = (Cp0 / numExps) * C00inv; 

S = struct('R_p_slice', R_p_slice);
save(fullfile(outDir, sprintf('R_p_slice_%03d.mat', p)), ...
     '-fromstruct', S, '-v7.3');
end
end

% ================= truncated SVD pseudoinverse =================
function Ainv = pinv_trunc(A)
% PINV_TRUNC  Truncated SVD pseudoinverse for better numerical stability.
% Keeps singular values > tau, where tau = relTol * (max(s) + eps).

    relTol = 1e-10;
    [U,S,V] = svd(A,'econ');
    s   = diag(S);
    tau = relTol * (max(s) + eps);

    keep = (s > tau);
    r    = sum(keep);
    n    = min(size(A));

    if r < n
        warning(['Matrix is (near-)singular: numerical rank = %d < %d. ', ...
                 'Using truncated SVD pseudoinverse (tau = %.3e).'], r, n, tau);
        pause(2);
    end

    s_inv = zeros(size(s));
    s_inv(keep) = 1 ./ s(keep);
    Ainv = V * diag(s_inv) * U.';
end

