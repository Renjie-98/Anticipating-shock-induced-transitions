function plot_obs_vs_sim()
% ============================================================
%  plot_obs_vs_sim · Compare observed vs simulated flight data
% ------------------------------------------------------------
%  Purpose:
%    This script compares observed and simulated flight activity
%    through three complementary analyses:
%       (1) Time series comparison
%       (2) Scatter correlation (Spearman & Pearson)
%       (3) Distribution comparison (Kolmogorov–Smirnov test)
%
%  REQUIRED FILES (in current folder):
%    - activity.mat   → contains 'activity'  (515 × 5537)
%    - X_p.mat        → contains 'X_p'       (515 × 5537)
%    - daily_data.csv → first column: dates
% ============================================================

%% ====== Load data ======
load('X_obs.mat', 'X_obs');
load('X_p.mat', 'X_p');
A = squeeze(X_obs);
B = squeeze(X_p);
yA = sum(A, 2);  % Observed total flights per day
yB = sum(B, 2);  % Simulated total flights per day

%% ====== Generate dates from file names ======
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\9.Passenger_flight';
files = dir(fullfile(dataDir, 'flight_*.csv'));
fileNames = {files.name};

% Extract date strings (remove prefix/suffix)
dateStrs = regexprep(fileNames, {'flight_', '.csv'}, {'', ''});
dates = datetime(dateStrs, 'InputFormat', 'yyyy-MM-dd');

% Sort by chronological order
[dates, sortIdx] = sort(dates);
yA = yA(sortIdx);
yB = yB(sortIdx);

%% ====== Common plot settings ======
set(groot, 'DefaultAxesFontName', 'Helvetica', ...
           'DefaultAxesFontSize', 14);
cSca = [0.55 0.20 0.70];

%% ====== Color definitions ======
blue_dark = [0.10 0.30 0.90];
blue_light = [0.70 0.82 1.00];
red_dark  = [0.85 0.20 0.20];
red_light = [1.00 0.78 0.78];
fillAlpha = 0.40;  % Uniform transparency for filled markers

figW = 12; figH = 9;  % cm

%% ====== (1) Time series comparison ======
% Lines: dark color; markers: light fill
figure('Units','centimeters','Position',[2 2 figW figH]);
hLineObs = plot(dates, yA, '-', 'Color', blue_dark, 'LineWidth', 2.5); hold on
hScatObs = scatter(dates, yA, 70, 'MarkerEdgeColor', blue_dark, ...
    'MarkerFaceColor', blue_light, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);
hScatObs.HandleVisibility = 'off';

hLineSim = plot(dates, yB, '-', 'Color', red_dark, 'LineWidth', 2.8);
hScatSim = scatter(dates, yB, 70, 'MarkerEdgeColor', red_dark, ...
    'MarkerFaceColor', red_light, 'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);
hScatSim.HandleVisibility = 'off';

% --- Legend: dummy “line + circle” handles for each dataset ---
hLegObs = plot(nan, nan, '-o', 'Color', blue_dark, ...
    'MarkerEdgeColor', blue_dark, 'MarkerFaceColor', blue_light, ...
    'LineWidth', 2.5, 'MarkerSize', 6);
hLegSim = plot(nan, nan, '-o', 'Color', red_dark, ...
    'MarkerEdgeColor', red_dark, 'MarkerFaceColor', red_light, ...
    'LineWidth', 2.8, 'MarkerSize', 6);

legend([hLegObs, hLegSim], {'Observed results', 'Predicted results'}, ...
       'Location', 'best', 'FontSize', 40);

% Hide dummy handles from axes (used only for legend)
set([hLegObs, hLegSim], 'XData', nan, 'YData', nan);
%xlabel('Date', 'FontSize', 16);
%ylabel('The total number of flights', 'FontSize', 16);
grid off;
legend off;
xtickformat('dd/MM/yyyy');
xtickangle(0);

% Set full date range with 5 evenly spaced ticks
xlim([dates(1) dates(end)]);

ax = gca;
tickIdx = round(linspace(1, numel(dates), 5));
ax.XTick = dates(tickIdx);
ax.XAxis.TickLabelFormat = 'MM/yyyy';
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size
% --- Y-axis: from 0 to 9e4 with 4 ticks ---
ylim([0 9.0e4]);
ax.YTick = linspace(0, 9.0e4, 3);    % ✅ 仅3条刻度线 (0, 4.5e4, 9e4)
ax.YTickLabel = [];                  % 不显示刻度文字
ax.YRuler.SecondaryLabel.Visible = 'off';  % 不显示 ×10^n
ax.YAxis.Exponent = 0;               % 禁止科学计数法


% --- 隐藏所有刻度值与科学计数标识 ---
ax.XTickLabel = [];              % 不显示 X 轴刻度数值
ax.YTickLabel = [];              % 不显示 Y 轴刻度数值
ax.YRuler.SecondaryLabel.Visible = 'off';  % 不显示 ×10^n
ax.YAxis.Exponent = 0;           % 禁止科学计数法自动出现

ax.LineWidth = 2;
ax.FontSize  = 30;      % 

%% ====== (2) Scatter correlation: Spearman & Pearson ======
idx = (yA > 0) & (yB > 0);
x = yA(idx);
y = yB(idx);
[rhoS, ~] = corr(x, y, 'Type', 'Spearman');
[rhoP, ~] = corr(x, y, 'Type', 'Pearson');

% --- Unified plot parameters ---
markerSize = 60;

figure('Units','centimeters','Position',[2 2 figW figH]);
scatter(x, y, markerSize, [0.55 0.20 0.70], 'filled', ...
        'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75); hold on;

% Plot 1:1 reference line
xyMax = 1.05 * max([x; y]);
xyMax = ceil(xyMax / 1e4) * 1e4;  % Round to nearest 10^4
plot([0 xyMax], [0 xyMax], 'k--', 'LineWidth', 1.0); hold off;

%xlabel('Observed results', 'FontSize', 16);
%ylabel('Predicted results', 'FontSize', 16);
%title(sprintf('\\bf%c = %.2f,  r = %.2f', 961, rhoS, rhoP), 'FontSize', 25); % ρ and r

% --- Layout and ticks ---
axis equal;
xlim([0 xyMax]); ylim([0 xyMax]);
box on; grid off;

ax = gca;
ax.FontSize = 28;
ax.FontName = 'Helvetica';
ax.XAxis.Exponent = 4;
ax.YAxis.Exponent = 4;


ax.TickLabelInterpreter = 'tex';

% --- Manual ticks including upper endpoint ---
M = 1e4;
ax.XTick = 0:M:xyMax;
ax.XTick = linspace(0, xyMax, 3); 
ax.YTick = linspace(0, xyMax, 3); 
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size


% --- 隐藏所有刻度值与科学计数标识 ---
ax.XTickLabel = [];              % 不显示 X 轴刻度数值
ax.YTickLabel = [];              % 不显示 Y 轴刻度数值
ax.YRuler.SecondaryLabel.Visible = 'off';  % 不显示 ×10^n
ax.YAxis.Exponent = 0;           % 禁止科学计数法自动出现

ax.LineWidth = 2;
ax.FontSize  = 45;      % 
%% ====== (3) Distribution comparison: KS test ======
figure('Units','centimeters','Position',[2 2 figW figH]);
edges = linspace(min([x; y]), max([x; y]), 35);

% --- Histogram comparison ---
h1 = histogram(x, edges, 'Normalization', 'probability', ...
               'FaceColor', blue_dark, 'FaceAlpha', 0.45);
hold on;
h2 = histogram(y, edges, 'Normalization', 'probability', ...
               'FaceColor', red_dark, 'FaceAlpha', 0.45);
hold off;

[~, ~, ksD] = kstest2(x, y);  % Kolmogorov–Smirnov test
%xlabel('The total number of flights', 'FontSize', 16);
%ylabel('Probability', 'FontSize', 16);
%title(sprintf('\\bfD = %.2f', ksD), 'FontSize', 16);

%legend([h1 h2], {'Observed results', 'Predicted results'}, ...
       %'Location', 'best', 'FontSize', 28);
grid off;
legend off;
ax = gca;
ax.FontSize = 28;
ax.FontName = 'Helvetica';
ax.TickLabelInterpreter = 'tex';

% --- Scientific notation (×10⁴) + enforce rightmost tick ---
xyMax = ceil(max([x; y]) / 1e4) * 1e4;
ax.XAxis.Exponent = 3;
xlim([0 xyMax]);
ax.XTick = linspace(0, xyMax, 3);
ylim([0 0.4]);                    
ax.YTick = linspace(0, 0.4, 3);   
set(gca,'Position',[0.15 0.15 0.75 0.75]);  % ✅ unify axis size


% --- 隐藏所有刻度值与科学计数标识 ---
ax.XTickLabel = [];              % 不显示 X 轴刻度数值
ax.YTickLabel = [];              % 不显示 Y 轴刻度数值
ax.YRuler.SecondaryLabel.Visible = 'off';  % 不显示 ×10^n
ax.YAxis.Exponent = 0;           % 禁止科学计数法自动出现

ax.LineWidth = 2;
ax.FontSize  = 37;      % 

end
