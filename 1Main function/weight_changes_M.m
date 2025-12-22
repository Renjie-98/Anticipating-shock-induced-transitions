function output_one = weight_changes_M(A, x0)
% WEIGHT_CHANGES_M
% Simulate gradual weakening of interaction weights on the FULL network.
% Edge weights are uniformly scaled by alpha from 1 down to 0.
% Output is M × N, each row is the steady state under that scaling.

    N  = size(A, 1);
    A0 = sparse(A);
    x0 = x0(:);

    % Weight scaling factors
    step_frac = 0.05;
    alphas = 1 : -step_frac : 0;     % scaling from 1 to 0
    if alphas(end) ~= 0
        alphas = [alphas, 0];        % ensure includes 0 exactly
    end
    M = numel(alphas);

    output_one = zeros(M, N);

    for step_idx = 1:M
        alpha = alphas(step_idx);

        % Scale interaction weights on the FULL network
        A_scaled = alpha * A0;

        % Run dynamics on the perturbed FULL network
        dummy_state = nan(1, N);
        dummy_state = iteration_real_M(1, dummy_state, A_scaled, x0);

        x_step = dummy_state(1, 1:N);
        output_one(step_idx, :) = x_step;
    end
end
