function [output_tstar, output_tminus, output_tplus] = weight_changes_M(A, x0)
% WEIGHT_CHANGES_M

    N  = size(A, 1);
    A0 = sparse(A);
    x0 = x0(:);

    % Scan weight removal ratio p from 0 (no removal) to 1 (all removed)
    step_frac = 0.1;
    p_list = 0 : step_frac : 1;     
    M = numel(p_list);

    output_tstar  = zeros(M, N);
    output_tminus = zeros(M, N);
    output_tplus  = zeros(M, N);
    
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
         [x_tstar, x_tminus, x_tplus] = iteration_real_M(A_scaled, x0);

        output_tstar(step_idx, :)  = x_tstar.';
        output_tminus(step_idx, :) = x_tminus.';
        output_tplus(step_idx, :)  = x_tplus.';
    end
end
