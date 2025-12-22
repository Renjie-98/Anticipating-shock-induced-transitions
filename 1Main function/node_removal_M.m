function output_one = node_removal_M(nnros, A, x0)
% NODE_REMOVAL_M
% Non-cumulative node removal on the FULL network.
% Removed nodes:
%   1) all interactions removed (rows/cols of A = 0)
%   2) node states are set to 0 and remain 0

    N  = size(A, 1);
    A0 = sparse(A);
    x0 = x0(:);

    removal_steps = 0:nnros:(N-1);
    M = numel(removal_steps);

    output_one = zeros(M, N);

    for step_idx = 1:M
        num_removed = removal_steps(step_idx);

        A_step = A0;
        x0_step = x0;

        if num_removed > 0
            removed = false(N,1);
            removed(randperm(N, num_removed)) = true;

            % (1) remove interactions
            A_step(removed,:) = 0;
            A_step(:,removed) = 0;

            % (2) removed node states fixed to zero
            x0_step(removed) = 0;
        end

        % Run dynamics
        dummy_state = nan(1, N);
        dummy_state = iteration_real_M(1, dummy_state, A_step, x0_step);
        x_step = dummy_state(1,1:N);

        % (3) enforce zero again (防止数值误差/模型自增长)
        if num_removed > 0
            x_step(removed) = 0;
        end

        output_one(step_idx,:) = x_step;
    end
end
