function plot_obs_vs_sim()
% ============================================================
%  plot_obs_vs_sim · Compare observed vs simulated fish data
% ------------------------------------------------------------
%  Purpose:
%    This function compares observed and simulated fish network
%    activity based on the *average node state* (mean redundancy per species).
%    It performs and visualizes three analyses:
%       (1) Time-series comparison
%       (2) Scatter correlation (Spearman & Pearson)
%       (3) Distribution comparison (K–S test)
%
%  REQUIRED FILES (in current folder):
%    - activity.mat  → contains 'activity'  (24 × 14)
%    - X_p.mat       → contains 'X_p'       (24 × 14)
% ============================================================

%% ====== Load data ======
load('X_obs.mat', 'X_obs');    % Observed fish network state
load('X_p.mat', 'X_p');              % Simulated fish network state
A = squeeze(X_obs);               % Observed (Y×N)
B = squeeze(X_p);                    % Simulated (Y×N)
yA = mean(A, 2);                     % ✅ Observed average node state
yB = mean(B, 2);                     % ✅ Simulated average node state

%% ====== Load date information from CSV ======
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\11.Ecosystem_fish';
stateFile = fullfile(dataDir, 'network state.csv');
T = readtable(stateFile, 'TextType', 'string');
T.Date = datetime(T.Date, 'InputFormat', 'yyyy/MM/dd');
dates = T.Date;

%% ====== Common plot settings ======
set(groot, 'DefaultAxesFontName', 'Helvetica', ...
           'DefaultAxesFontSize', 14);
cSca = [0.55 0.20 0.70];

% ====== Color definitions (consistent with flight network) ======
blue_dark = [0.10 0.30 0.90];
blue_light = [0.70 0.82 1.00];
red_dark  = [0.85 0.20 0.20];
red_light = [1.00 0.78 0.78];
fillAlpha = 0.40;

figW = 12; figH = 9;  % cm

%% ---------- (1) Time series ----------
figure('Units','centimeters','Position',[2 2 figW figH]);
plot(dates, yA, '-', 'Color', blue_dark, 'LineWidth', 2.5); hold on
scatter(dates, yA, 70, 'MarkerEdgeColor', blue_dark, ...
        'MarkerFaceColor', blue_light, ...
        'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

plot(dates, yB, '-', 'Color', red_dark, 'LineWidth', 2.8);
scatter(dates, yB, 70, 'MarkerEdgeColor', red_dark, ...
        'MarkerFaceColor', red_light, ...
        'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

%xlabel('Year', 'FontSize', 25);
%ylabel('Average species abundance', 'FontSize', 25);

% --- Legend: dummy “line + circle” handles for each dataset ---
hLegObs = plot(nan, nan, '-o', 'Color', blue_dark, ...
    'MarkerEdgeColor', blue_dark, 'MarkerFaceColor', blue_light, ...
    'LineWidth', 2.5, 'MarkerSize', 6);
hLegSim = plot(nan, nan, '-o', 'Color', red_dark, ...
    'MarkerEdgeColor', red_dark, 'MarkerFaceColor', red_light, ...
    'LineWidth', 2.8, 'MarkerSize', 6);

lgd = legend([hLegObs, hLegSim], {'Observed results', 'Predicted results'}, ...
             'Location', 'best', 'FontSize', 9);
lgd.Box = 'off';

% Hide dummy handles from the plot (only used for legend)
set([hLegObs, hLegSim], 'XData', nan, 'YData', nan);

grid off; box on;
datetick('x', 'yyyy', 'keeplimits');

% ===== Force display of first and last years =====
ax = gca;
ax.XLim = [dates(1) dates(end)];                 % Ensure full range visible
ax.XTick = linspace(dates(1), dates(end), 6);    % Evenly spaced tick marks
ax.XTickLabel = cellstr(datestr(ax.XTick, 'yyyy'));

% ===== Add top margin for Y-axis =====
ylim([0 100]);
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size



ax.XTickLabel = [];            
ax.YTickLabel = [];             
ax.YRuler.SecondaryLabel.Visible = 'off';  
ax.YAxis.Exponent = 0;           

ax.FontSize  = 30;  
ax.LineWidth = 2;

%% ---------- (2) Scatter: Spearman & Pearson ----------
idx = (yA > 0) & (yB > 0);
x = yA(idx);
y = yB(idx);
[rhoS, ~] = corr(x, y, 'Type', 'Spearman');
[rhoP, ~] = corr(x, y, 'Type', 'Pearson');

figure('Units','centimeters','Position',[2 2 figW figH]);
scatter(x, y, 65, cSca, 'filled', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75); hold on;
xyMax = 1.05 * max([x; y]);
plot([0 xyMax], [0 xyMax], 'k--'); hold off;

%xlabel('Observed results', 'FontSize', 16);
%ylabel('Predicted results', 'FontSize', 16);
%title(sprintf('%c = %.3f,  r = %.3f', 961, rhoS, rhoP), 'FontSize', 16);

axis equal;

% Expand and round axis limits to nearest 10
xyMax = 1.05 * max([x; y]);   
xyMax = ceil(xyMax / 10) * 10; 
xlim([0 xyMax]);
ylim([0 xyMax]);

% --- Force ticks to include 0 and upper limit ---
ax = gca;
ax.XTick = linspace(0, xyMax, 3);
ax.YTick = linspace(0, xyMax, 3);
ax.XTickLabel = arrayfun(@(v) sprintf('%g', v), ax.XTick, 'UniformOutput', false);
ax.YTickLabel = arrayfun(@(v) sprintf('%g', v), ax.YTick, 'UniformOutput', false);

box on; grid off;
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
h1 = histogram(x, edges, 'Normalization', 'probability', ...
               'FaceColor', blue_dark, 'FaceAlpha', 0.45);
hold on;
h2 = histogram(y, edges, 'Normalization', 'probability', ...
               'FaceColor', red_dark, 'FaceAlpha', 0.45);
hold off;

[~, ~, ksD] = kstest2(x, y);  % Kolmogorov–Smirnov test

%xlabel('Average species abundance', 'FontSize', 16);
%ylabel('Probability', 'FontSize', 16);
%title(sprintf('D = %.3f', ksD), 'FontSize', 16);   % ✅ Show D only (omit p-value)
%legend([h1 h2], {'Observed results', 'Predicted results'}, ...
       %'Location', 'best', 'FontSize', 28);

grid off; box on;
legend off;
% ===== Force display of full X-axis range =====
xMax = ceil(max([x; y]) / 10) * 10;   % Round up to nearest multiple of 10
xlim([0 xMax]);
ax = gca;
ax.XTick = linspace(0, xMax, 3);      
ax.XTickLabel = arrayfun(@(v) sprintf('%g', v), ax.XTick, 'UniformOutput', false);

% ===== Adjust Y-axis to leave top margin =====
ylim([0, 0.3]);
ax.YTick = linspace(0, 0.3, 3);     
ax.FontSize = 28;
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size

ax.XTickLabel = [];             
ax.YTickLabel = [];              
ax.YRuler.SecondaryLabel.Visible = 'off';  % 不显示 ×10^n
ax.YAxis.Exponent = 0;           
ax.LineWidth = 2;
ax.FontSize  = 37;      

end
end

