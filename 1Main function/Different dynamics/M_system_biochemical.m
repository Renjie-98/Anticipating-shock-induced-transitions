function Fv = M_system(t,x,A)
%   M_system describes the biochemical dynamic
%
%   Fv = M_system(t,x,A)
%
%   Inputs:
%       t : The time
%       x : The state vector of all nodes
%       A : Adjacency matrix of the network
%
%   Outputs:
%       Fv : the derivative of state x
%


%---Parameters for biochemical dynamic-----------
F = 0.5; 
B = 0.1; 
R = 1;
%---Parameters for biochemical dynamic-----------

Fv = F - B.*x - R.*(x .* (A * x));

end
