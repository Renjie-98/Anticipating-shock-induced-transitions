function output_one = weight_changes_M(A, x0)
% WEIGHT_CHANGES_M

    N  = size(A, 1);
    A0 = sparse(A);
    x0 = x0(:);

    % Scan weight removal ratio p from 0 (no removal) to 1 (all removed)
    step_frac = 0.05;
    p_list = 0 : step_frac : 1;     
    M = numel(p_list);
    output_one = zeros(M, N);
    
    for step_idx = 1:M
        p = p_list(step_idx);      
        alpha = 1 - p; 
     
      if alpha < 0.5
        perturbation = 2 * alpha * rand(N, N);
        Adj_pert = perturbation .* A0;
      else
        perturbation = (2 - 2 * alpha) * rand(N, N);
        Adj_pert = A0 - perturbation .* A0;
      end  
       A_scaled = Adj_pert;

        % Run dynamics and record the steady state
        dummy_state = nan(1, N);
        dummy_state = iteration_real_M(1, dummy_state, A_scaled, x0);
        output_one(step_idx, :) = dummy_state(1, 1:N);
    end
end
