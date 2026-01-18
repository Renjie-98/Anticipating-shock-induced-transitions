function plot_obs_vs_sim()
% ============================================================
%  plot_obs_vs_sim · Compare observed vs simulated trade data
% ------------------------------------------------------------
%  Purpose:
%    This script compares observed and simulated trade activity
%    through three complementary analyses:
%       (1) Time series comparison
%       (2) Scatter correlation (Spearman & Pearson)
%       (3) Distribution comparison (Kolmogorov–Smirnov test)
%
%  REQUIRED FILES (in current folder):
%    - X_obs.mat   → contains 'X_obs'  (515 × 5537)
%    - X_p.mat        → contains 'X_p'       (515 × 5537)
% ============================================================

%% ====== Load data ======
load('X_obs.mat', 'X_obs');    % Observed trade state
load('X_p.mat', 'X_p');              % Simulated trade state
A = squeeze(X_obs);               
B = squeeze(X_p);                    
yA = sum(A, 2);                      % Total observed trade values
yB = sum(B, 2);                      % Total simulated trade values

%% ====== Load year information ======
dataDir = 'C:\Users\xuren\Desktop\NP-real\Data\10.Economy_trade';
files = dir(fullfile(dataDir, 'trade_*TOTAL_new.csv'));
fileNames = {files.name};
yearStrs = regexp(fileNames, '\d{4}', 'match', 'once');
years = sort(str2double(yearStrs(~cellfun('isempty', yearStrs))));

% Ensure baseline year 2008 is included
if ~isempty(years) && min(years) >= 2009
    years = [2008; years(:)];
end

% Fallback: sequential years if mismatch with data length
if isempty(years) || numel(years) ~= numel(yA)
    years = (2008 : 2008 + numel(yA) - 1)';
end

%% ====== Common plot settings ======
set(groot, 'DefaultAxesFontName', 'Helvetica', ...
           'DefaultAxesFontSize', 14);
blue_dark = [0.10 0.30 0.90];
blue_light = [0.70 0.82 1.00];
red_dark  = [0.85 0.20 0.20];
red_light = [1.00 0.78 0.78];
fillAlpha = 0.40;

figW = 12; figH = 9;  % cm

%% ---------- (1) Time series ----------
figure('Units','centimeters','Position',[2 2 figW figH]);

% Observed results (blue)
plot(years, yA, '-', 'Color', blue_dark, 'LineWidth', 2.5); hold on
scatter(years, yA, 70, 'MarkerEdgeColor', blue_dark, ...
        'MarkerFaceColor', blue_light, ...
        'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

% Simulated results (red)
plot(years, yB, '-', 'Color', red_dark, 'LineWidth', 2.8);
scatter(years, yB, 70, 'MarkerEdgeColor', red_dark, ...
        'MarkerFaceColor', red_light, ...
        'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

%xlabel('Year', 'FontSize', 16);
%ylabel('Total trade volume', 'FontSize', 16);

% Legend with dummy handles (line + circle)
hLegObs = plot(nan, nan, '-o', 'Color', blue_dark, ...
    'MarkerEdgeColor', blue_dark, 'MarkerFaceColor', blue_light, ...
    'LineWidth', 2.5, 'MarkerSize', 6);
hLegSim = plot(nan, nan, '-o', 'Color', red_dark, ...
    'MarkerEdgeColor', red_dark, 'MarkerFaceColor', red_light, ...
    'LineWidth', 2.8, 'MarkerSize', 6);

legend([hLegObs, hLegSim], {'Observed results', 'Simulated results'}, ...
       'Location', 'best', 'FontSize', 40);
set([hLegObs, hLegSim], 'XData', nan, 'YData', nan);
grid off; box on;
legend off;



ax = gca;
% Y-axis range
yMin = 8e12; 
yMax = 14e12;
ylim([yMin, yMax]);
ax.YTick = linspace(yMin, yMax, 3);  % 
numTicks = 5;                              
xlim([years(1) years(end)]);              
tickIdx = round(linspace(1, numel(years), numTicks));
ax.XTick = years(tickIdx);                
ax.XTickLabel = [];                        
ax.YAxis.Exponent = 13;       % Scientific notation ×10^13
ytickformat('%.1f');          % Force display with 1 decimal (1 → 1.0)
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size

ax.XTickLabel = [];              
ax.YTickLabel = [];              
ax.YRuler.SecondaryLabel.Visible = 'off';  % 不显示 ×10^n
ax.YAxis.Exponent = 0;          

ax.LineWidth = 2;
ax.FontSize  = 30;      
%% ====== (2) Scatter correlation ======
idx = (yA > 0) & (yB > 0);
x = yA(idx); 
y = yB(idx);

% Compute Spearman and Pearson correlations
[rhoS, ~] = corr(x, y, 'Type', 'Spearman');
[rhoP, ~] = corr(x, y, 'Type', 'Pearson');

figure('Units','centimeters','Position',[2 2 figW figH]);
scatter(x, y, 60, [0.55 0.20 0.70], 'filled', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75); hold on;

% 1:1 reference line
xyMin = 8e12; 
xyMax = 14e12;
plot([xyMin xyMax], [xyMin xyMax], 'k--', 'LineWidth', 1.0); hold off;

%xlabel('Observed results', 'FontSize', 16);
%ylabel('Simulated results', 'FontSize', 16);
%title(sprintf('\\bf%c = %.3f,  r = %.3f', 961, rhoS, rhoP), 'FontSize', 16);

% Layout
axis equal;
xlim([xyMin xyMax]); 
ylim([xyMin xyMax]);
box on; grid off;

ax = gca;
ax.XTick = linspace(xyMin, xyMax, 3);  
ax.YTick = linspace(xyMin, xyMax, 3);   

tickStep = 2e12;  % Tick spacing
ax.XAxis.Exponent = 13;       % Keep scientific notation
ax.YAxis.Exponent = 13;
xtickformat('%.1f');          % Force decimal style
ytickformat('%.1f');
ax.FontSize = 28;            
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size

ax.XTickLabel = [];              
ax.YTickLabel = [];              
ax.YRuler.SecondaryLabel.Visible = 'off';  
ax.YAxis.Exponent = 0;           

ax.LineWidth = 2;
ax.FontSize  = 37;      

%% ---------- (3) Distribution: KS test ----------
figure('Units','centimeters','Position',[2 2 figW figH]);
edges = linspace(min([x; y]), max([x; y]), 25);

% Histograms
h1 = histogram(x, edges, 'Normalization', 'probability', ...
               'FaceColor', blue_dark, 'FaceAlpha', 0.45);
hold on;
h2 = histogram(y, edges, 'Normalization', 'probability', ...
               'FaceColor', red_dark, 'FaceAlpha', 0.45);
hold off;

% Kolmogorov–Smirnov test
[~, ~, ksD] = kstest2(x, y);

%xlabel('Total trade volume', 'FontSize', 16);
%ylabel('Probability', 'FontSize', 16);
%title(sprintf('D = %.3f', ksD), 'FontSize', 16);

%legend([h1 h2], {'Observed results', 'Simulated results'}, ...
       %'Location', 'best', 'FontSize', 28);

grid off; box on;
legend off;
% X-axis range and ticks
xlim([8e12 14e12]);
ax = gca;
ax.XTick = linspace(8e12, 14e12, 3);
ax.XAxis.Exponent = 13;       % Scientific notation ×10^13
xtickformat('%.1f');          % Force decimal style (1 → 1.0)

% Y-axis range
ylim([0, 0.2]);
yticks(0:0.1:0.2);
ax.FontSize = 28;            
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size

ax.XTickLabel = [];             
ax.YTickLabel = [];              
ax.YRuler.SecondaryLabel.Visible = 'off'; 
ax.YAxis.Exponent = 0;           
ax.LineWidth = 2;
ax.FontSize  = 37;      

end

