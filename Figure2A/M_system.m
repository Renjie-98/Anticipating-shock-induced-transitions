function Fv = M_system(t,x,A)
%   M_system describes Noisy Voter dynamics
%
%   Fv = M_system(t,x,A)
%
%   Inputs:
%       t : The time
%       x : The state vector of all nodes (probability of adopting opinion "1")
%       A : Adjacency matrix of the network
%   Outputs:
%       Fv : the derivative of state x
%    
% 
%

%---Parameters for Noisy Voter dynamics-----------
A0 = 0.2;   % noise term: spontaneous transition
B  = 2.0;   % noise term: spontaneous recovery
C  = 1.8;   % neighbor imitation strength
%---Parameters for Noisy Voter dynamics-----------

[i,j,s] = find(A);          % edge list: i<-j with weight s
N = length(x);

% global maximum degree
deg = sum(A,2);             
kmax = max(deg);            
if kmax == 0
    kmax = 1;  
end

% Self term + neighbor imitation
Fv = zeros(N,1);
for steps = 1:length(i)
    Fv(i(steps)) = Fv(i(steps)) + (C/kmax) * s(steps) * x(j(steps));
end

% Add noise terms
Fv = Fv + A0 - B.*x;

end
