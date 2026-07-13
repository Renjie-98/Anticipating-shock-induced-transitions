function output_one = iteration_real_M(steps, output_one, A, x0)
% ITERATION_REAL_M
% Integrate the  dynamics with environmental/demographic multiplicative
% Gaussian white noise using the Euler-Maruyama method.
%
% Stochastic differential equation:
%
%   dx_i = f_i(x) dt + lambda*x_i*dW_i
%   dx_i = f_i(x) dt + lambda*sqrt(x_i)*dW_i
%
% Euler-Maruyama discretization :
% Environmental noise:
%   x_i(q+1) = x_i(q)
%              + f_i(x(q))*h
%              + lambda*x_i(q)*sqrt(h)*Z_i(q)
% Demographic noise
%   x_i(q+1) = x_i(q)
%              + f_i(x(q))*h
%              + lambda*sqrt(x_i(q))*sqrt(h)*Z_i(q)

% where Z_i(q) ~ N(0,1).
%
% Inputs:
%   steps      : row index used to store the result
%   output_one : output matrix
%   A          : adjacency matrix
%   x0         : initial state
%
% Output:
%   output_one : long-term mean state under environmental noise

% Simulation interval
t0 = 0;
tf = 100;

% Fixed Euler-Maruyama time step
h = 0.01;

% Environmental noise intensity
lambda = 1e-2;

% Use the interval to calculate the long-term mean
average_start = 80;

% Total number of numerical integration steps
num_steps = round((tf - t0) / h);

% Ensure that the initial state is a column vector
x = x0(:);

% Number of nodes
n = length(x);

% Variables for calculating the temporal average
x_sum = zeros(n, 1);
sample_count = 0;

for q = 1:num_steps

    % Current time
    current_time = t0 + (q - 1) * h;

    % Deterministic part f(x)
    drift = M_system(current_time, x, A);

    % Independent Wiener increments for different nodes
    %
    % dW_i = sqrt(h)*Z_i, where Z_i ~ N(0,1)
    dW = sqrt(h) .* randn(n, 1);

    % Euler-Maruyama update with environmental multiplicative noise
    x = x + drift .* h + lambda .* x .* dW;

    % Euler-Maruyama update with demographic multiplicative noise
    %x = x + drift .* h ...+ lambda .* sqrt(x) .* dW;
    
    x = max(x, 0);
    % Check for numerical divergence
    if any(~isfinite(x))
        error(['Non-finite state encountered at t = %.4f. ', ...
               'Try reducing h or lambda.'], current_time + h);
    end

    % Calculate the temporal mean over [80, 100]
    if current_time + h >= average_start

        x_sum = x_sum + x;
        sample_count = sample_count + 1;

    end

end

% Ensure that averaging samples were collected
if sample_count == 0
    error('No samples were collected for temporal averaging.');
end

% Long-term temporal mean state
xl_ss = x_sum ./ sample_count;

% Store the result in the specified row
output_one(steps, 1:length(xl_ss)) = xl_ss';

end