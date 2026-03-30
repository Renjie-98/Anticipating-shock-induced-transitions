function Fv = M_system(t,x,A)
%   M_system describes the Birth-death (population) dynamics
%
%   Fv = M_system(t,x,A)
%
%   Inputs:
%       t : The time
%       x : The state vector of all nodes (N × 1)
%       A : Adjacency matrix of the network (N × N)
%
%   Outputs:
%       Fv : the derivative of state x (N × 1)
%

%--- Parameters for birth-death dynamics --------
a = 1;      % exponent for incoming interaction
b = 2;      % exponent for decay
B = 1;      % death rate coefficient
R = 1;      % interaction coefficient
%-----------------------------------------------

% Birth-death equation
Fv = -B .* (x.^b) + R .* (A * (x.^a));

end
