function Fv = M_system(t,x,A)
%   M_system describes Kuramoto synchronization dynamics
%
%   Fv = M_system(t,x,A)
%
%   Inputs:
%       t : The time
%       x : The state vector of all nodes (phases, in radians)
%       A : Adjacency matrix of the network
%       x_low = 1;  
%   Outputs:
%       Fv : the derivative of state x
%    
% 
%

%---Parameters for Kuramoto dynamics-----------
R = 1;        % coupling strength
persistent w
if isempty(w) || length(w) ~= length(x)
  
    stream = RandStream('mt19937ar','Seed',123);  
    w = -1 + 2*rand(stream,length(x),1);   % w_i ∈ [-1,1]
end
[i,j,s] = find(A);          % edge list: i<-j with weight s

% Self term: natural frequency
Fv = w ;

for k = 1:length(i)
    Fv(i(k)) = Fv(i(k)) + R * s(k) * sin(x(j(k)) - x(i(k)));
end

end
