function generate_T()
% ------------------------------------------------------------
%  Purpose:
%  This function processes daily flight CSV data to construct:
%   (1) A baseline-day transition matrix (row-normalized)
%   (2) Daily airport outbound activity time series
%   (3) Directed link removal ratios relative to the baseline
%
%  INPUT:
%    • Data folder (fixed path):
%        9.Passenger_flight network
%
%  OUTPUT (saved in current script folder):
%    • T.mat        → Row-normalized transition matrix (baseline day)
%    • activity.mat  → Airport outbound activity (F × N)
%    • ratios.mat    → Directed link removal ratios (F × 1)
%
clc;
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\9.Passenger_flight';  % Input folder (CSV data)
outDir  = fileparts(mfilename('fullpath'));  % Current script folder (output path)

%% ------------------------------------------------------------
%  Step 1: Build weighted row-normalized transition matrix (T)
% -------------------------------------------------------------
fprintf('\n=== Step 1: Building baseline transition matrix T ===\n');

% Read baseline day data (example: 2020-02-21)
Tdata = readtable(fullfile(dataDir, 'flight_2020-02-21.csv'), 'TextType', 'string');
W = ones(height(Tdata), 1);  % Every link counts as 1 flight

% Build airport index
[airports, ~, ic] = unique([Tdata.Source; Tdata.Target], 'stable');
N = numel(airports);
origIdx = ic(1:height(Tdata));          
destIdx = ic(height(Tdata)+1:end);      

% Construct transition adjacency and row-normalize
Acount = accumarray([origIdx destIdx], W, [N N], @sum, 0);
T = Acount ./ sum(Acount, 2);
T(isnan(T)) = 0;

% Save result → current folder
save(fullfile(outDir, 'T.mat'), 'T', 'airports', '-v7.3');

%% ------------------------------------------------------------
%  Step 2: Compute airport activity (weighted outbound flights)
% -------------------------------------------------------------
fprintf('\n=== Step 2: Computing activity.mat ===\n');

% Get all flight_*.csv files
files = dir(fullfile(dataDir, 'flight_*.csv'));
fileList = string(sort({files.name}));
F = numel(fileList);

% Build global airport index across all days
allPorts = [];
for k = 1:F
    Ttmp = readtable(fullfile(files(k).folder, fileList(k)), 'TextType', 'string');
    allPorts = [allPorts; Ttmp.Source; Ttmp.Target];
end
airports = unique(allPorts, 'stable');
N = numel(airports);

% Initialize activity matrix (F days × N airports)
X_obs = zeros(F, N);
for k = 1:F
    Ttmp = readtable(fullfile(files(k).folder, fileList(k)), 'TextType', 'string');
    [~, oIdx] = ismember(Ttmp.Source, airports);   % oIdx: Source -> index
    X_obs(k,:) = accumarray(oIdx, 1, [N 1], @sum, 0).';
end

% Save result → current folder
save(fullfile(outDir, 'X_obs.mat'), 'X_obs', 'airports', '-v7.3');

%% ------------------------------------------------------------
%  Step 3: Compute perturbation ratios (relative to baseline)
% -------------------------------------------------------------
fprintf('\n=== Step 3: Computing ratios.mat ===\n');

linkCounts = zeros(F, 1);
for k = 1:F
    Ttmp = readtable(fullfile(files(k).folder, fileList(k)), 'TextType', 'string');
    linkCounts(k)  = height(unique(Ttmp(:, {'Source', 'Target'}), 'rows'));
end

ratios = (linkCounts(1) - linkCounts) / linkCounts(1);

save(fullfile(outDir, 'ratios.mat'), 'ratios', '-v7.3');

end

