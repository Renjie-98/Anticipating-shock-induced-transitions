function output_one = iteration_real_M(steps, output_one, A, x0)
% ITERATION_REAL_M
% Run dynamics on network A and stop early when near steady state.

t0 = 0;
%tf = 550;  %NV(t*)=5.5  %tf=550   
tf = 30;  %SIS(t*)=0.3  %tf=30   
%tf = 140;  %P(t*)=1.4  %tf=140   


%t2 = linspace(5.5, tf, 500);   NV
tspan = [0, logspace(-5, log10(5.5), 1500), t2(2:end)]; NV

t2 = linspace(0.3, tf, 500);  % SIS
tspan = [0, logspace(-5, log10(0.3), 1500), t2(2:end)]; %SIS

%t2 = linspace(1.4, tf, 500);    P
%tspan = [0, logspace(-5, log10(1.4), 1500), t2(2:end)]; P



[t, x] = ode45(@(t,x) M_system(t, x, A), tspan, x0);

T = numel(tspan);
output_one(steps:steps+T-1, 1:size(x,2)) = x;

alpha = 0.01;
x_ss = x(end, :)';
rel_err = vecnorm((x' - x_ss), 2, 1)' / norm(x_ss, 2);

idx_star = find(rel_err <= alpha, 1, 'first');

if isempty(idx_star)
    idx_star = T;
end

t_star = t(idx_star);

%fprintf('t* = %.6f\n', t_star);

end
