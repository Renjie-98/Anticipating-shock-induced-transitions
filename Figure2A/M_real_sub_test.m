function M_real_sub_test(the_net)
% M_REAL_SUB_TEST
% Generate ONE merged testing tensor by stacking all realizations and all
% initial conditions along the first dimension:
%   (num_x0*num_reali) × nn × mm

dataPath = 'F:\SI\FunctionA\2.Epidemics (SIS)_MIT Reality Mining.mat';
S = load(dataPath);
[~, netName, ~] = fileparts(dataPath);

A = sparse(S.A);
n = size(A,1);
nnlros =1416;

%708 %1416

%19 %37

num_reali = 100;     % realizations per initial condition
num_x0    = 10;      % number of initial conditions
x_0       = 0;
sigma     = 1;
perturbation_type = 2;   % single type; extend if needed

% --- probe output size (nn × mm) once ---
x0_probe =  x_0*ones(n,1) + sigma * rand(n,1);
tmp = Perturpation_real_M(nnlros, A, perturbation_type, x0_probe);
[nn, mm] = size(tmp);

% --- allocate merged testing tensor ---
%% 
%X_test = zeros(num_x0*num_reali, nn, mm);
X_test = zeros(num_x0*num_reali, nn+1, mm);
%% 
row0 = 0;  % write pointer along the 1st dimension

for k = 1:num_x0
    x0 = x_0*ones(n,1) + sigma * rand(n,1);

    % collect realizations for this x0
    outputs = zeros(num_reali, nn, mm);
    seeds = randi(2^31-1, num_reali, 1);

    parfor realization = 1:num_reali
           rng(seeds(realization), 'twister');
           tmp_r = Perturpation_real_M(nnlros, A, perturbation_type, x0);

        % pad/truncate to fixed nn×mm
        tmp2 = zeros(nn, mm);
        nn_r = min(size(tmp_r,1), nn);
        mm_r = min(size(tmp_r,2), mm);
        tmp2(1:nn_r, 1:mm_r) = tmp_r(1:nn_r, 1:mm_r);
        outputs(realization,:,:) = tmp2;
    end

    % stack into the global tensor
    rows = row0 + (1:num_reali);
    X_test(rows,1,:)     = repmat(reshape(x0,1,1,mm), numel(rows), 1, 1);
    X_test(rows,2:end,:) = outputs;
    row0 = row0 + num_reali;
    fprintf('perturbation type %d | x0 #%d completed (%d/%d)\n', ...
            perturbation_type, k, k, num_x0);
end

% --- save ONE file ---

baseFolder = 'compute data/2.Epidemics (SIS)_MIT Reality Mining_perturbation_type2-0.6';

save(fullfile(baseFolder,'X_test.mat'),'X_test','sigma','perturbation_type','-v7.3');

assignin('base', 'X_test', X_test);


end
