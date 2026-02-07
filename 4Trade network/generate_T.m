function generate_T()
% ------------------------------------------------------------
%  Purpose:
%  Process multi-year trade CSV data to compute:
%    (1) Baseline-year row-normalized trade transition matrix
%    (2) Annual country export activity
%    (3) Relative perturbation ratios (weight loss)
%
%  INPUT:
%    • Data folder (fixed path):
%        10.Economy_trade
%
%  OUTPUT (saved in current script folder):
%    • T.mat        →   Row-normalized transition matrix (baseline day)
%    • X_obs.mat  →     Network activity (F × N)
%    • ratios.mat    →  Weight loss ratios (F × 1)
%
clc;
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\10.Economy_trade';  
outDir  = fileparts(mfilename('fullpath'));                       

%% ------------------------------------------------------------
%  Step 1: Build weighted row-normalized transition matrix (T)
% -------------------------------------------------------------
fprintf('\n=== Step 1: Building baseline transition matrix T ===\n');

% Read baseline year data (e.g., 2008)
Tdata = readtable(fullfile(dataDir, 'trade_2008-TOTAL_new.csv'), 'TextType', 'string' );
W = double(Tdata.Weight);

% Build countries index
[countries, ~, ic] = unique([Tdata.Source; Tdata.Target], 'stable');
N = numel(countries);
origIdx = ic(1:height(Tdata));
destIdx = ic(height(Tdata)+1:end);

% Construct transition adjacency and row-normalize
Acount = accumarray([origIdx destIdx], W, [N N], @sum, 0);
T = Acount ./ sum(Acount, 2);
T(isnan(T)) = 0;  

% Save baseline transition matrix to .mat file
save(fullfile(outDir, 'T.mat'), 'T', 'countries', '-v7.3');

%% ------------------------------------------------------------
%  Step 2: Compute annual export activity 
% -------------------------------------------------------------
fprintf('\n=== Step 2: Computing activity.mat ===\n');

% Get all trade_*.csv files
files = dir(fullfile(dataDir, 'trade_*TOTAL_new.csv'));
fileList = string(sort({files.name}));
F = numel(fileList);  

% Build a global list of all countries across all years
allNodes = [];
for k = 1:F
    Tk = readtable(fullfile(files(k).folder, fileList(k)), 'TextType', 'string');
    allNodes = [allNodes; Tk.Source; Tk.Target];
end
countries = unique(allNodes, 'stable');
N = numel(countries);

% Initialize activity matrices （Y years × N countries）
X_obs = zeros(F, N);  % Annual export activity
for k = 1:F
    Tk = readtable(fullfile(files(k).folder, fileList(k)), 'TextType', 'string');
    w = double(Tk.Weight);
    [~, oIdx] = ismember(Tk.Source, countries);
    X_obs(k, :) = accumarray(oIdx, w, [N 1], @sum, 0).';
end

% Save annual export activity
save(fullfile(outDir, 'X_obs.mat'), 'X_obs', 'countries', '-v7.3');

%% ------------------------------------------------------------
%  Step 3: Compute perturbation ratios (relative to baseline)
% -------------------------------------------------------------
fprintf('\n=== Step 3: Computing ratios.mat ===\n');

linkCounts   = zeros(F, 1);
totalWeights = zeros(F, 1);
for k = 1:F
    Tk = readtable(fullfile(files(k).folder, fileList(k)), 'TextType', 'string');
    w = double(Tk.Weight);
    totalWeights(k) = sum(w);
end

p_weight = (totalWeights(1) - totalWeights) / totalWeights(1);

ratios = [p_weight(:)];

save(fullfile(outDir, 'ratios.mat'), 'ratios', '-v7.3');

end











