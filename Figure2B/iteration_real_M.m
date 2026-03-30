function [x_tstar, x_tminus, x_tplus] = iteration_real_M(A, x0)
% ITERATION_REAL_M
% Run dynamics once and return states at t*, t-, and t+.

t0 = 0;

%t_star = 5.5;
%t_star = 0.3;
t_star = 1.4;

tspan = [0, logspace(-5, log10(t_star), 1500)];


[t, x] = ode45(@(t,x) M_system(t, x, A), tspan, x0);

f_minus = 0.05;   % t- = f- * t*
f_plus  = 0.2;  % t+ = f+ * t*
t_minus = f_minus * t_star;
t_plus  = f_plus  * t_star;

[~, idx_star]  = min(abs(t - t_star));
[~, idx_minus] = min(abs(t - t_minus));
[~, idx_plus]  = min(abs(t - t_plus));

x_tstar  = x(idx_star, :)';
x_tminus = x(idx_minus, :)';
x_tplus  = x(idx_plus, :)';

%fprintf('t*      = %.6f\n', t(idx_star));
%fprintf('t_minus = %.6f\n', t(idx_minus));
%fprintf('t_plus  = %.6f\n', t(idx_plus));
end