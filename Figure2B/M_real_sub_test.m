function [X_test_tstar, X_test_tminus, X_test_tplus] = M_real_sub_test(the_net)
% M_REAL_SUB_TEST
% Generate three merged testing tensors:
%   X_test_tstar
%   X_test_tminus
%   X_test_tplus
%
% Each tensor size:
%   (num_x0*num_reali) × (nn+1) × mm

dataPath = 'F:\SI\0Data\6.Population_Little Rock Lake.mat';
S = load(dataPath);
[~, netName, ~] = fileparts(dataPath);

A = sparse(S.A);
n = size(A,1);
nnlros =  0;
% NV nnlros = 6;
% SIS nnlros = 236;

num_reali = 100;     % realizations per initial condition
num_x0    = 10;      % number of initial conditions
x_0       = 0;
sigma     = 1;
perturbation_type = 3;

% --- probe output size once ---
x0_probe = x_0*ones(n,1) + sigma * rand(n,1);
[tmp_tstar, tmp_tminus, tmp_tplus] = Perturpation_real_M(nnlros, A, perturbation_type, x0_probe);
[nn, mm] = size(tmp_tstar);

% --- allocate merged testing tensors ---
X_test_tstar  = zeros(num_x0*num_reali, nn+1, mm);
X_test_tminus = zeros(num_x0*num_reali, nn+1, mm);
X_test_tplus  = zeros(num_x0*num_reali, nn+1, mm);

row0 = 0;

for k = 1:num_x0
    x0 = x_0*ones(n,1) + sigma * rand(n,1);

    % collect realizations for this x0
    outputs_tstar  = zeros(num_reali, nn, mm);
    outputs_tminus = zeros(num_reali, nn, mm);
    outputs_tplus  = zeros(num_reali, nn, mm);

    seeds = randi(2^31-1, num_reali, 1);

    parfor realization = 1:num_reali
        rng(seeds(realization), 'twister');

        [tmp_tstar_r, tmp_tminus_r, tmp_tplus_r] = ...
            Perturpation_real_M(nnlros, A, perturbation_type, x0);

        % --- t* ---
        tmp2 = zeros(nn, mm);
        nn_r = min(size(tmp_tstar_r,1), nn);
        mm_r = min(size(tmp_tstar_r,2), mm);
        tmp2(1:nn_r, 1:mm_r) = tmp_tstar_r(1:nn_r, 1:mm_r);
        outputs_tstar(realization,:,:) = tmp2;

        % --- t- ---
        tmp2 = zeros(nn, mm);
        nn_r = min(size(tmp_tminus_r,1), nn);
        mm_r = min(size(tmp_tminus_r,2), mm);
        tmp2(1:nn_r, 1:mm_r) = tmp_tminus_r(1:nn_r, 1:mm_r);
        outputs_tminus(realization,:,:) = tmp2;

        % --- t+ ---
        tmp2 = zeros(nn, mm);
        nn_r = min(size(tmp_tplus_r,1), nn);
        mm_r = min(size(tmp_tplus_r,2), mm);
        tmp2(1:nn_r, 1:mm_r) = tmp_tplus_r(1:nn_r, 1:mm_r);
        outputs_tplus(realization,:,:) = tmp2;
    end

    % stack into global tensors
    rows = row0 + (1:num_reali);

    X_test_tstar(rows,1,:)     = repmat(reshape(x0,1,1,mm), numel(rows), 1, 1);
    X_test_tstar(rows,2:end,:) = outputs_tstar;

    X_test_tminus(rows,1,:)     = repmat(reshape(x0,1,1,mm), numel(rows), 1, 1);
    X_test_tminus(rows,2:end,:) = outputs_tminus;

    X_test_tplus(rows,1,:)     = repmat(reshape(x0,1,1,mm), numel(rows), 1, 1);
    X_test_tplus(rows,2:end,:) = outputs_tplus;

    row0 = row0 + num_reali;

    fprintf('perturbation type %d | x0 #%d completed (%d/%d)\n', ...
            perturbation_type, k, k, num_x0);
end

% --- save ONE file ---
baseFolder = 'compute data';
saveFolder = fullfile(baseFolder, sprintf('%s_perturbation_type%d', netName, perturbation_type));
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

filename = fullfile(saveFolder, 'X_test.mat');
save(filename, ...
    'X_test_tstar', 'X_test_tminus', 'X_test_tplus', ...
    'sigma', 'perturbation_type', '-v7.3');

% also save to base workspace
assignin('base', 'X_test_tstar', X_test_tstar);
assignin('base', 'X_test_tminus', X_test_tminus);
assignin('base', 'X_test_tplus', X_test_tplus);

% extra backup in current folder
save('X_test_backup.mat', ...
    'X_test_tstar', 'X_test_tminus', 'X_test_tplus', ...
    'sigma', 'perturbation_type', '-v7.3');
end