function output_one = weight_changes_M(A, x0)
% WEIGHT_CHANGES_M

    N  = size(A, 1);
    A0 = sparse(A);
    x0 = x0(:);

    % Scan weight removal ratio p from 0 (no removal) to 1 (all removed)
    p_list = 0.6;     
    M = numel(p_list);

    % ---- time settings (must match iteration_real_M) ----
   % t0 = 0; tf = 100; dt = 0.01;
   % T = numel(t0:dt:tf);

tspan = [0.01:0.01:0.1, 0.11:0.1:1, 2:1000];
T = numel(tspan);

    % ---- allocate: (M*T) × N ----
    output_one = zeros(M*T, N);
    
    for step_idx = M
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
        startRow = (step_idx-1)*T + 1;
        output_one = iteration_real_M(startRow, output_one, A_scaled, x0);
    end
end
