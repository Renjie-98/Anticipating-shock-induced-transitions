function Fv = M_system(t,x,A)
%   M_system describes the neuronal dynamic (Cowan-Wilson model)
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


%---Parameters for neuronal dynamic-----------
B = 2;
R = 1; 
tau = 5; 
mu = 0;

%---Parameters for neuronal dynamic-----------

Fv = -B.*x + R.*(A * (1 ./ (1 + exp(-tau.*(x - mu)))));

end
