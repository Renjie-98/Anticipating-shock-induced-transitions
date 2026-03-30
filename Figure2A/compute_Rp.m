function compute_Rp()
% COMPUTE_RP
% Estimate linear response operators R_p.
%
% For each perturbation p:
%   x_p ≈ R_p x_0
% with
%   R_p = C_{p0} C_{00}^

    %% --- 1. Load training data ---
    folderPath = 'compute data/2.Epidemics (SIS)_MIT Reality Mining_perturbation_type2-0.6';
    files = dir(fullfile(folderPath, '*.mat'));
    M = numel(files);

    %% ---the revised (begin) ---  
    tmp = load(fullfile(folderPath, files(1).name), 'outputs', 'x0');
    % x0 represent the initial state.
    %% ---the revised (end) ---
    [~, P, N] = size(tmp.outputs);
    
    X0   = zeros(M, N);     
    Xbar = zeros(M, P, N);
    for i = 1:M
        D = load(fullfile(folderPath, files(i).name), 'outputs', 'x0');
        X0(i,:) = D.x0(:).';
        Xbar(i,:,:) = mean(D.outputs, 1);
    end

    %% ---------- reference covariance ----------
    C00 = zeros(N, N);
    for i = 1:M
        x0i = (X0(i,:) ).';
        C00 = C00 + x0i * x0i.';
    end

    C00 = C00 / M;

    C00_inv = pinv_trunc(C00);

    %% ---------- response operators ----------
    R_p = zeros(N, N, P);

    for p = 1:P
        Xp  = squeeze(Xbar(:,p,:));

        Cp0 = zeros(N, N);
        for i = 1:M
            xpi = Xp(i,:).';
            x0i = X0(i,:).';
            Cp0 = Cp0 + xpi * x0i.';
        end
        Cp0 = Cp0 / M;

        Rp = Cp0 * C00_inv;
        R_p(:,:,p) = Rp;
    end

save(fullfile(folderPath, 'R_p.mat'), 'R_p', '-v7.3');

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
