function compute_R_p_slice()
% ============================================================
%  Purpose:
%  Estimate linear response operators (R_p, b_p) from the training tensor Y
%
%  INPUT:
%    • train_set.mat → Y (numExps × numPerturb × numNodes)
%
%  OUTPUT (unchanged format: slice-by-slice files):
%    • Folder: R_p_slices
%        - R_p_slice_XXX.mat contains:
%            R_p_slice  (numNodes × numNodes)
%            b_p_slice  (numNodes × 1)
% ============================================================

%% ------------ Load Y ------------
load('train_set.mat', 'Y');
data3D = Y;
[numExps, numPerturb, numNodes] = size(data3D);

%% ------------ Compute baseline mean mu0 and covariance C00 ------------
% X0: numExps × numNodes (baseline states)
X0  = squeeze(data3D(:, 1, :));          % baseline across experiments
mu0 = mean(X0, 1);                        % 1 × numNodes

C00 = zeros(numNodes, numNodes, 'double');
for i = 1:numExps
    x0c = (X0(i,:) - mu0).';              % centered baseline (numNodes × 1)
    C00 = C00 + x0c * x0c.';              % accumulate outer product
end
C00 = C00 / numExps;

% Truncated SVD pseudoinverse for numerical stability
C00inv = pinv_trunc(C00);

%% ------------ Create output folder (unchanged) ------------
outDir = 'R_p_slices';
if ~exist(outDir,'dir'), mkdir(outDir); end

%% ------------ Compute and save each R_p slice ------------
for p = 1:numPerturb
    fprintf('→ Computing and saving slice %3d / %3d of R_p ...\n', p, numPerturb);
    Xp  = squeeze(data3D(:, p, :));
    mup = mean(Xp, 1);                    
    Cp0 = zeros(numNodes, numNodes, 'double');
    for i = 1:numExps
        xpc = (Xp(i,:) - mup).';          % centered perturbed
        x0c = (X0(i,:) - mu0).';          % centered baseline
        Cp0 = Cp0 + xpc * x0c.';
    end
    Cp0 = Cp0 / numExps;

    R_p_slice = Cp0 * C00inv;                             % numNodes × numNodes
    b_p_slice = mup.' - R_p_slice * mu0.';                % numNodes × 1

    save(fullfile(outDir, sprintf('R_p_slice_%03d.mat', p)), ...
         'R_p_slice', 'b_p_slice', '-v7.3');
end

fprintf('\n✓ All %d slices saved in folder "%s".\n', numPerturb, outDir);
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
