function Fv = M_system(t,x,A)
%   M_system describes the gene regulatory dynamic
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


%---Parameters for gene regulatory dynamic-----------
f = 1; h = 1;
%---Parameters for gene regulatory dynamic-----------

Fv = -x.^f+A*(x.^h./(x.^h+1));