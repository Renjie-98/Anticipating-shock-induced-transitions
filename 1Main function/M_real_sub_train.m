function M_real_sub_train(the_net)
% M_REAL_SUB_TRAIN
% Generate baseline-level training data by simulating perturbation responses
% from multiple random initial conditions and saving each ensemble separately.
dataPath = 'C:\Users\xuren\Desktop\NP-real\0Data\1.Mutualistic_Coral Reefs.mat';
load(dataPath);
[~, netName, ~] = fileparts(dataPath);

A = sparse(A);                 % network adjacency matrix
n = size(A,1);                 % number of nodes
nnlros = 1;                    % model parameter

num_reali = 100;             % number of realizations per initial condition
num_x0 = 20;                % number of initial conditions
x_0 = 0;                     % baseline initial state （not real）
sigma  = 1;                  % noise amplitude for initial conditions

for perturbation_type = 1:1  % loop over perturbation types
    % --- probe output dimensions (nn × mm) ---
    x0_train = x_0*ones(n,1) + sigma * rand(n,1);
    tmp = Perturpation_real_M(nnlros, A, perturbation_type, x0_train);
    [nn, mm] = size(tmp);

    % --- generate training data for each initial condition ---
    for k = 1:num_x0
       
        % random initial condition
        x0 = x_0*ones(n,1) + sigma * rand(n,1);

        % outputs(realization, state, time/perturb index)
        outputs = zeros(num_reali, nn, mm);

        % simulate multiple realizations (parallelized)
        seeds = randi(2^31-1, num_reali, 1);

        parfor realization = 1:num_reali
             rng(seeds(realization), 'twister');
            tmp_r = Perturpation_real_M(nnlros, A, perturbation_type, x0);

            % pad or truncate output to fixed size
            tmp2 = zeros(nn, mm);
            nn_r = min(size(tmp_r,1), nn);
            mm_r = min(size(tmp_r,2), mm);
            tmp2(1:nn_r, 1:mm_r) = tmp_r(1:nn_r, 1:mm_r);

            outputs(realization,:,:) = tmp2;
        end

        % --- save one file per initial condition ---
        baseFolder = 'compute data';
        saveFolder = fullfile(baseFolder, ...
            sprintf('%s_perturbation_type%d', netName, perturbation_type));

        if ~exist(saveFolder, 'dir')
            mkdir(saveFolder);
        end

        filename = fullfile(saveFolder, sprintf('x0%03d.mat', k));
        save(filename, 'outputs', 'x0', 'sigma', 'perturbation_type', '-v7.3');

        fprintf('perturbation type %d | x0 #%d completed (%d/%d)\n', ...
                perturbation_type, k, k, num_x0);
    end
end
end


