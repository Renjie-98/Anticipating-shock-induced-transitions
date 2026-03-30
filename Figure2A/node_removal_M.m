function output_one = node_removal_M(nnros, A, x0)
% NODE_REMOVAL_M
% Non-cumulative node removal on the FULL network.
% Removed nodes:
%   1) all interactions removed (rows/cols of A = 0)
%   2) node states are set to 0 and remain 0

    N  = size(A, 1);
    A0 = sparse(A);
    x0 = x0(:);

    removal_steps = nnros;
    M = numel(removal_steps);

    % ---- time settings (must match iteration_real_M) ----
   % t0 = 0; tf = 1000; dt = 0.01;
   % T = numel(t0:dt:tf);
tf = 550;  %NV=5.5  %tf=550
t2 = linspace(5.5, tf, 500);
tspan = [0, logspace(-5, log10(5.5), 1500), t2(2:end)];

T = numel(tspan);
   %tspan = logspace(log10(0.1), log10(1000), 200);

% T = numel(tspan);

    % ---- allocate: (M*T) × N ----
    output_one = zeros(M*T, N);

    for step_idx = M
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
        startRow = (step_idx-1)*T + 1;
        output_one = iteration_real_M(startRow, output_one, A_step, x0_step);
        % (3) enforce zero again 
        if num_removed > 0
            rows = startRow:startRow+T-1;
            output_one(rows, removed) = 0;
        end
    end
end
