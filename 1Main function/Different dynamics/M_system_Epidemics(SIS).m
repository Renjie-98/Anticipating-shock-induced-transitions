function Fv = M_system(t,x,A)
%   M_system describes the SIS epidemic dynamics
%
%   Fv = M_system(t,x,A)
%
%   Inputs:
%       t : The time
%       x : The state vector of all nodes (infection probability in [0,1])
%       A : Adjacency matrix of the network
%       x_low = 1;  
%   Outputs:
%       Fv : the derivative of state x
%    
% 
%

%---Parameters for SIS dynamics-----------
B = 5;   % recovery rate
R = 1;   % infection (transmission) rate
%---Parameters for SIS dynamics-----------
% x_begin = 1; 

[i,j,s] = find(A);          % edge list: i<-j with weight s

% Self term: recovery
Fv = -B .* x;

% Interaction term: infections via neighbors
for steps = 1:length(i)
    Fv(i(steps)) = Fv(i(steps)) + R * s(steps) * (1 - x(i(steps))) * x(j(steps));
end
end