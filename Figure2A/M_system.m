function Fv = M_system(t,x,A)
%   M_system describes the mutualistic dynamics
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
%   See also R_system. 
%

%---Parameters for mutualistic dynamics-----------
K  = 5;      % Carrying capacity
AA = 1;      % Allee effect parameter
D  = 5;      % Half-saturation constant
E  = 0.9;    % Self-regulation factor
H  = 0.1;    % Partner-regulation factor
%---Parameters for mutualistic dynamics-----------

% Initialize self-dynamics (Allee effect with logistic growth)
Fv = (0.1 - x .* (x./K - 1) .* (x./AA - 1));

% Add pairwise mutualistic interactions
[i,j,s] = find(A);
for k = 1:length(i)
    Fv(i(k)) = Fv(i(k)) + s(k) * x(i(k)) * x(j(k)) / ...
               (D + E * x(i(k)) + H * x(j(k)));
end

end
