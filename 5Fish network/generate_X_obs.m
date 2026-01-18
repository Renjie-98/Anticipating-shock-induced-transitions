function generate_X_obs()
% ============================================================
%  Purpose:
%  Extract node-level ecosystem states and compute
%  structural and functional perturbation ratios
%  relative to a fixed baseline date (2002/07/05).
%
%  INPUT:
%    • Data folder (fixed path):
%        11.Ecosystem_fish
%        network state.csv (Date + node states)
%
%  OUTPUT:
%    • X_obs.mat   → node state matrix (F × N)
%    • ratios.mat  → perturbation ratios (F × 2):
%        - col 1: node removal ratio
%        - col 2: state decline ratio
% ============================================================
clc;
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\11.Ecosystem_fish';  % Input folder
outDir  = fileparts(mfilename('fullpath'));                         % Current script folder (for outputs)

%% ------------------------------------------------------------
%  Step 1: Build weighted row-normalized transition matrix (T)
% -------------------------------------------------------------
fprintf('\n=== Step 1: Computing activity.mat ===\n');

% Read fish ecosystem state data
stateFile = fullfile(dataDir, 'network state.csv');    
S = readtable(stateFile, 'TextType', 'string');
S.Date = datetime(S.Date, 'InputFormat', 'yyyy/MM/dd');

species = string(S.Properties.VariableNames(2:end));   % node names
X_obs   = double(table2array(S(:, 2:end)));            % Y × N state matrix

% --- Save activity matrix ---
save(fullfile(outDir, 'X_obs.mat'), 'X_obs', 'species', '-v7.3');

%% ------------------------------------------------------------
%  Step 2: Compute perturbation ratios
% -------------------------------------------------------------
fprintf('\n=== Step 2: Computing ratios.mat (baseline = 2002/7/5) ===\n');

baselineIdx = find(S.Date == datetime(2002,7,5), 1);

totalStates  = sum(X_obs, 2);       % Total network state at each time

baselineState  = totalStates(baselineIdx);
p_stateDecline = (baselineState - totalStates) / max(baselineState, eps);

ratios =  [p_stateDecline(:)];

save(fullfile(outDir, 'ratios.mat'), 'ratios', '-v7.3');

end

