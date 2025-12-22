function output_one = iteration_real_M(steps, output_one, A, x0)
% ITERATION_REAL_M
% Run dynamics on network A and stop early when near steady state.

t0 = 0;
tf = 300;

tol_dx = 1e-5;

% Event function (no extra parameters passed by ode45)
options = odeset('Events', @steady_event);

% ODE function with A captured by anonymous function
[t, x] = ode45(@(t,x) M_system(t, x, A), [t0, tf], x0, options);

xl_ss = x(end, :)';
output_one(steps, 1:length(xl_ss)) = xl_ss;

    function [value, isterminal, direction] = steady_event(t, x)
        dx = M_system(t, x, A);
        value = norm(dx, inf) - tol_dx;
        isterminal = 1;
        direction  = -1;
    end
end
