function compute_Rp()
% COMPUTE_RP
% Estimate three linear response operators:
%   x_p(t*)   ≈ R_p_tstar  x_0
%   x_p(t-)   ≈ R_p_tminus x_0
%   x_p(t+)   ≈ R_p_tplus  x_0

    %% --- 1. Load training data ---
    folderPath = 'compute data/6.Population_Little Rock Lake_perturbation_type3';
    files = dir(fullfile(folderPath, '*.mat'));
    M = numel(files);

    tmp = load(fullfile(folderPath, files(1).name), ...
        'outputs_tstar', 'outputs_tminus', 'outputs_tplus', 'x0');

    [~, P, N] = size(tmp.outputs_tstar);

    X0          = zeros(M, N);
    Xbar_tstar  = zeros(M, P, N);
    Xbar_tminus = zeros(M, P, N);
    Xbar_tplus  = zeros(M, P, N);

    %% --- 2. Collect mean responses ---
    for i = 1:M
        D = load(fullfile(folderPath, files(i).name), ...
            'outputs_tstar', 'outputs_tminus', 'outputs_tplus', 'x0');

        X0(i,:) = D.x0(:).';

        Xbar_tstar(i,:,:)  = mean(D.outputs_tstar, 1);
        Xbar_tminus(i,:,:) = mean(D.outputs_tminus, 1);
        Xbar_tplus(i,:,:)  = mean(D.outputs_tplus, 1);
    end

    %% --- 3. Reference covariance C00 ---
    C00 = zeros(N, N);
    for i = 1:M
        x0i = X0(i,:).';
        C00 = C00 + x0i * x0i.';
    end
    C00 = C00 / M;

    C00_inv = pinv_trunc(C00);

    %% --- 4. Response operators ---
    R_p_tstar  = zeros(N, N, P);
    R_p_tminus = zeros(N, N, P);
    R_p_tplus  = zeros(N, N, P);

    for p = 1:P
        % ----- t* -----
        Xp = squeeze(Xbar_tstar(:,p,:));
        Cp0 = zeros(N, N);
        for i = 1:M
            xpi = Xp(i,:).';
            x0i = X0(i,:).';
            Cp0 = Cp0 + xpi * x0i.';
        end
        Cp0 = Cp0 / M;
        R_p_tstar(:,:,p) = Cp0 * C00_inv;

        % ----- t- -----
        Xp = squeeze(Xbar_tminus(:,p,:));
        Cp0 = zeros(N, N);
        for i = 1:M
            xpi = Xp(i,:).';
            x0i = X0(i,:).';
            Cp0 = Cp0 + xpi * x0i.';
        end
        Cp0 = Cp0 / M;
        R_p_tminus(:,:,p) = Cp0 * C00_inv;

        % ----- t+ -----
        Xp = squeeze(Xbar_tplus(:,p,:));
        Cp0 = zeros(N, N);
        for i = 1:M
            xpi = Xp(i,:).';
            x0i = X0(i,:).';
            Cp0 = Cp0 + xpi * x0i.';
        end
        Cp0 = Cp0 / M;
        R_p_tplus(:,:,p) = Cp0 * C00_inv;
    end

    %% --- 5. Save ---
    save(fullfile(folderPath, 'R_p.mat'), ...
        'R_p_tstar', 'R_p_tminus', 'R_p_tplus', '-v7.3');

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