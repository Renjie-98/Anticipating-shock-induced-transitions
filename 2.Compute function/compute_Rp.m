function [R_p, b_p] = compute_Rp()
% COMPUTE_RP
% Estimate linear response operators R_p and offsets b_p from baseline ensembles.
%
% For each perturbation p:
%   x_p ≈ R_p x_0 + b_p
% with
%   R_p = C_{p0} C_{00}^+ ,   b_p = μ_p − R_p μ_0

    %% --- 1. Load training data ---
    folderPath = 'compute data/1.Mutualistic_Coral Reefs_perturbation_type1';
    files = dir(fullfile(folderPath, '*.mat'));
    M = numel(files);

    tmp = load(fullfile(folderPath, files(1).name), 'outputs');
    [~, P, N] = size(tmp.outputs);

    Xbar = zeros(M, P, N);
    for i = 1:M
        S = load(fullfile(folderPath, files(i).name), 'outputs');
        Xbar(i,:,:) = mean(S.outputs, 1);
    end

    %% ---------- reference covariance ----------
    X0  = squeeze(Xbar(:,1,:));
    mu0 = mean(X0, 1);

    C00 = zeros(N, N);
    for i = 1:M
        xi = (X0(i,:) - mu0).';
        C00 = C00 + xi * xi.';
    end
    C00 = C00 / M;
    C00_inv = pinv_trunc(C00);

    %% ---------- response operators ----------
    R_p = zeros(N, N, P);
    b_p = zeros(N, P);

    for p = 1:P
        Xp  = squeeze(Xbar(:,p,:));
        mup = mean(Xp, 1);

        Cp0 = zeros(N, N);
        for i = 1:M
            xpi = (Xp(i,:) - mup).';
            x0i = (X0(i,:) - mu0).';
            Cp0 = Cp0 + xpi * x0i.';
        end
        Cp0 = Cp0 / M;

        Rp = Cp0 * C00_inv;
        R_p(:,:,p) = Rp;
        b_p(:,p)   = mup.' - Rp * mu0.';
    end

    save(fullfile(folderPath, 'R_p_b_p.mat'), 'R_p', 'b_p');
end


% ================= truncated SVD pseudoinverse =================
function Ainv = pinv_trunc(A)
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
