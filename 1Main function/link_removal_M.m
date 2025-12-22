function output_one = link_removal_M(nnros, A, x0)
% LINK_REMOVAL_M
% Non-cumulative link removal on the FULL network.
% At each step, remove a new set of edges from the original network A0
% (edges are not accumulated across steps).
% Output is M × N, each row is the steady state under that perturbation.

    N  = size(A,1);
    A0 = sparse(A);
    isUndir = issymmetric(A0);
    x0 = x0(:);

    %% Build edge list on the FULL network
    [row_idx, col_idx] = edge_list_full(A0, isUndir);
    total_edges = numel(row_idx);

    %% Define removal steps (non-cumulative)
    removal_steps = 0:nnros:total_edges;
    if removal_steps(end) < total_edges
        removal_steps = [removal_steps, total_edges];
    end
    M = numel(removal_steps);

    % One random edge order used across steps (progressively remove more)
    edge_order = randperm(total_edges);

    output_one = zeros(M, N);

    %% Main loop: always start from the original FULL network
    for step_idx = 1:M
        num_remove = removal_steps(step_idx);
        A_step = A0;

        if num_remove > 0
            rem_idx = edge_order(1:num_remove);
            i = row_idx(rem_idx);
            j = col_idx(rem_idx);

            if isUndir
                % Remove both (i,j) and (j,i)
                A_step(sub2ind([N,N], i, j)) = 0;
                A_step(sub2ind([N,N], j, i)) = 0;
            else
                % Remove directed edges (i,j)
                A_step(sub2ind([N,N], i, j)) = 0;
            end
        end

        % Run dynamics on the perturbed FULL network
        dummy_state = nan(1, N);
        dummy_state = iteration_real_M(1, dummy_state, A_step, x0);
        x_step = dummy_state(1, 1:N);

        output_one(step_idx, :) = x_step;
    end
end


function [r, c] = edge_list_full(A, isUndir)
% EDGE_LIST_FULL
% Extract edge indices within the FULL network.
% For undirected networks, only upper-triangular edges are kept.
% For directed networks, keep all nonzero off-diagonal edges.

    if isUndir
        [r, c] = find(triu(A, 1));
    else
        [r, c] = find(A);
        keep = (r ~= c);   % exclude self-loops
        r = r(keep);
        c = c(keep);
    end
end
