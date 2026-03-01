function Y = gen_train_set()

clc;
nTrials      = 1000;               
outFile      = 'train_set.mat';  
load('T.mat','T');
load('X_obs.mat','X_obs');
load('ratios.mat','ratios');

nodeRatios   = ratios(:,1);          
nRatios      = size(ratios,1);
T = double(T);               
N = size(T, 1);
X0 = X_obs(1,:);         % Baseline node state (first observation)

%% ------------ Parallel perturbation loop ------------
Y = zeros(nTrials, nRatios, N, 'double');
for p = 1:nRatios
    k  = nodeRatios(p);    % node loss
   for m = 1:nTrials
    node = randperm(N, k);
    Tpert = T;                    
    Tpert(node,:) = 0;           % remove outgoing edges
    Y(m, p, :) = X0 * Tpert;     
   end
end

%% ------------ Post-processing and save ------------
%for m = 1:nTrials
   % Y(m,1,:) = reshape(X0, [1 1 N]);  % Include baseline activity
%end

save(outFile, 'Y', '-v7.3');        
end
