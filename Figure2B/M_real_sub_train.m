function M_real_sub_train(the_net)
% M_REAL_SUB_TRAIN

dataPath = 'F:\SI\0Data\6.Population_Little Rock Lake.mat';
load(dataPath);
[~, netName, ~] = fileparts(dataPath);

A = sparse(A);
n = size(A,1);
nnlros = 0;

% NV nnlros = 6;
% SIS nnlros = 236;


num_reali = 100;
num_x0 = 100;
x_0 = 0;
sigma = 1;

for perturbation_type = 3:3
    % probe output size
    x0_train = x_0*ones(n,1) + sigma * rand(n,1);
    [tmp_tstar, tmp_tminus, tmp_tplus] = Perturpation_real_M(nnlros, A, perturbation_type, x0_train);
    [nn, mm] = size(tmp_tstar);

    for k = 1:num_x0
        x0 = x_0*ones(n,1) + sigma * rand(n,1);

        outputs_tstar  = zeros(num_reali, nn, mm);
        outputs_tminus = zeros(num_reali, nn, mm);
        outputs_tplus  = zeros(num_reali, nn, mm);

        seeds = randi(2^31-1, num_reali, 1);

        parfor realization = 1:num_reali
            rng(seeds(realization), 'twister');

            [tmp_tstar_r, tmp_tminus_r, tmp_tplus_r] = ...
                Perturpation_real_M(nnlros, A, perturbation_type, x0);

            % t*
            tmp2 = zeros(nn, mm);
            nn_r = min(size(tmp_tstar_r,1), nn);
            mm_r = min(size(tmp_tstar_r,2), mm);
            tmp2(1:nn_r, 1:mm_r) = tmp_tstar_r(1:nn_r, 1:mm_r);
            outputs_tstar(realization,:,:) = tmp2;

            % t-
            tmp2 = zeros(nn, mm);
            nn_r = min(size(tmp_tminus_r,1), nn);
            mm_r = min(size(tmp_tminus_r,2), mm);
            tmp2(1:nn_r, 1:mm_r) = tmp_tminus_r(1:nn_r, 1:mm_r);
            outputs_tminus(realization,:,:) = tmp2;

            % t+
            tmp2 = zeros(nn, mm);
            nn_r = min(size(tmp_tplus_r,1), nn);
            mm_r = min(size(tmp_tplus_r,2), mm);
            tmp2(1:nn_r, 1:mm_r) = tmp_tplus_r(1:nn_r, 1:mm_r);
            outputs_tplus(realization,:,:) = tmp2;
        end

        baseFolder = 'compute data';
        saveFolder = fullfile(baseFolder, ...
            sprintf('%s_perturbation_type%d', netName, perturbation_type));

        if ~exist(saveFolder, 'dir')
            mkdir(saveFolder);
        end

        filename = fullfile(saveFolder, sprintf('x10%03d.mat', k));
        save(filename, ...
            'outputs_tstar', 'outputs_tminus', 'outputs_tplus', ...
            'x0', 'sigma', 'perturbation_type', '-v7.3');

        fprintf('perturbation type %d | x0 #%d completed (%d/%d)\n', ...
            perturbation_type, k, k, num_x0);
    end
end
end