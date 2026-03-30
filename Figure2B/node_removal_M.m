function [output_tstar, output_tminus, output_tplus] = node_removal_M(nnros, A, x0)
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

    output_tstar  = zeros(M, N);
    output_tminus = zeros(M, N);
    output_tplus  = zeros(M, N);

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

        % Run dynamics only once, get three time-scale states
        [x_tstar, x_tminus, x_tplus] = iteration_real_M(A_step, x0_step);

        % (3) enforce zero again
        if num_removed > 0
            x_tstar(removed)  = 0;
            x_tminus(removed) = 0;
            x_tplus(removed)  = 0;
        end

        output_tstar(step_idx,:)  = x_tstar.';
        output_tminus(step_idx,:) = x_tminus.';
        output_tplus(step_idx,:)  = x_tplus.';
    end
end