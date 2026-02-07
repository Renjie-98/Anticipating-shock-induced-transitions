function generate_T()
% ============================================================
%  Purpose:
%  Extract node-level ecosystem states and compute
%  structural perturbation ratios relative to a fixed baseline date.

%  Process multi-year trade CSV data to compute:
%    (1) Baseline-year row-normalized trade transition matrix
%    (2) Annual the redundancy of species
%    (3) Relative perturbation ratios (node loss)
% 
%  INPUT:
%    • Data folder (fixed path):
%        11.Ecosystem_fish
%
%  OUTPUT (saved in current script folder):
%    • T.mat        →  Row-normalized transition matrix (baseline day)
%    • X_obs.mat  →    Network state (F × N)
%    • ratios.mat    → Node loss ratios (F × 1)
% ============================================================
clc;
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\11.Ecosystem_fish';  % Input folder
outDir  = fileparts(mfilename('fullpath'));                         % Current script folder (for outputs)

%% ------------------------------------------------------------
%  Step 1: Build weighted row-normalized transition matrix (T)
% -------------------------------------------------------------
fprintf('\n=== Step 1: Building baseline transition matrix T ===\n');

% --- 1) Read state file to get species order ---
S = readtable(fullfile(dataDir, 'network state.csv'), 'TextType','string');
species = string(S.Properties.VariableNames(2:end));   % keep this order
N = numel(species);

% --- 2) Read network structure ---
Tdata = readtable(fullfile(dataDir, 'network structure.csv'), 'TextType','string');
W = ones(height(Tdata), 1);

% --- 3) Map Source / Target to indices using fixed species order ---
[~, origIdx] = ismember(string(Tdata.Source), species);
[~, destIdx] = ismember(string(Tdata.Target), species);

% --- 4) Build adjacency and row-normalize ---
Acount = accumarray([origIdx destIdx], W, [N N], @sum, 0);
T = Acount ./ sum(Acount, 2);
T(isnan(T)) = 0;

% --- 5) Save ---
save(fullfile(outDir, 'T.mat'), 'T', 'species', '-v7.3');

%% ------------------------------------------------------------
%  Step 2: Compute species activity
% -------------------------------------------------------------
fprintf('\n=== Step 2: Computing X_obs.mat ===\n');

X_obs = double(table2array(S(:,2:end)));

save(fullfile(outDir, 'X_obs.mat'), 'X_obs', 'species', '-v7.3');

%% ------------------------------------------------------------
%  Step 3: Compute perturbation ratios
% -------------------------------------------------------------
fprintf('\n=== Step 3: Computing ratios.mat (baseline = 2002/6/1) ===\n');

removedMask = (X_obs == 0);
p_nodeRemoved = mean(removedMask, 2);   % Y × 1, in [0,1]
ratios = p_nodeRemoved(:);
save(fullfile(outDir, 'ratios.mat'), 'ratios', '-v7.3');

end










