function plot_obs_vs_sim()

%% ====== Load data ======
S1 = load('X_obs.mat','X_obs');
S2 = load('X_p.mat','X_p');

A  = squeeze(S1.X_obs);
B  = squeeze(S2.X_p);

yA = sum(A, 2);                 % observed total
yB = sum(B, 2);                 % simulated total

% Force column vectors (avoid plot dimension errors)
yA = yA(:);
yB = yB(:);

%% ====== Build years ======
dataDir = 'C:\Users\xuren\Desktop\NP-real\0Data\10.Economy_trade';
files   = dir(fullfile(dataDir,'trade_*TOTAL_new.csv'));
yearStr = regexp({files.name}, '\d{4}', 'match', 'once');
years   = sort(str2double(yearStr(~cellfun('isempty',yearStr))));
years   = years(:);

% Ensure baseline year 2008 is included
if ~isempty(years) && min(years) >= 2009
    years = [2008; years];
end

% Fallback if mismatch
if isempty(years) || numel(years) ~= numel(yA)
    years = (2008 : 2008 + numel(yA) - 1)';
end

% Ensure same length for safety
n = min([numel(years), numel(yA), numel(yB)]);
years = years(1:n);
yA    = yA(1:n);
yB    = yB(1:n);

%% ====== Common plot settings ======
blue_dark  = [0.10 0.30 0.90];
blue_light = [0.70 0.82 1.00];
red_dark   = [0.85 0.20 0.20];
red_light  = [1.00 0.78 0.78];
fillAlpha  = 0.40;

figW = 12; figH = 9;     % cm
pos  = [0.15 0.15 0.75 0.75];

yMin = 8e12; 
yMax = 14e12;

%% ---------- (1) Time series ----------
figure('Units','centimeters','Position',[2 2 figW figH]); hold on

plot(years, yA, '-', 'Color', blue_dark, 'LineWidth', 2.5);
scatter(years, yA, 70, 'o', ...
    'MarkerEdgeColor', blue_dark, 'MarkerFaceColor', blue_light, ...
    'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

plot(years, yB, '-', 'Color', red_dark, 'LineWidth', 2.8);
scatter(years, yB, 70, '^', ...
    'MarkerEdgeColor', red_dark, 'MarkerFaceColor', red_light, ...
    'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

ax = gca;
box on; grid off;
xlim([years(1) years(end)]);
ylim([yMin yMax]);

ax.XTick = years(round(linspace(1, numel(years), 5)));
ax.YTick = linspace(yMin, yMax, 3);

ax.XTickLabel = [];
ax.YTickLabel = [];
ax.YRuler.SecondaryLabel.Visible = 'off';
ax.YAxis.Exponent = 0;

ax.LineWidth = 2;
ax.FontSize  = 30;
set(gca,'Position',pos);

%% ---------- (2) Scatter correlation ----------
idx = (yA > 0) & (yB > 0);
x = yA(idx);
y = yB(idx);

% Compute Spearman and Pearson correlations
[rhoS, ~] = corr(x, y, 'Type', 'Spearman');
[rhoP, ~] = corr(x, y, 'Type', 'Pearson');

figure('Units','centimeters','Position',[2 2 figW figH]); hold on
scatter(x, y, 60, [0.55 0.20 0.70], 'filled', ...
    'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.75);

plot([yMin yMax], [yMin yMax], 'k--', 'LineWidth', 1.0);

% Keep your title (rho and r)
%title(sprintf('\\bf%c = %.3f,  r = %.3f', 961, rhoS, rhoP), ...
      %'FontSize', 16);

axis equal;
xlim([yMin yMax]);
ylim([yMin yMax]);
box on; grid off;

ax = gca;
ax.XTick = linspace(yMin, yMax, 3);
ax.YTick = linspace(yMin, yMax, 3);

ax.XTickLabel = [];
ax.YTickLabel = [];
ax.YRuler.SecondaryLabel.Visible = 'off';
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;

ax.LineWidth = 2;
ax.FontSize  = 37;
set(gca,'Position',pos);

%% ---------- (3) Distribution: KS test ----------
figure('Units','centimeters','Position',[2 2 figW figH]); hold on
edges = linspace(min([x; y]), max([x; y]), 25);

histogram(x, edges, 'Normalization','probability', ...
    'FaceColor', blue_dark, 'FaceAlpha', 0.45);
histogram(y, edges, 'Normalization','probability', ...
    'FaceColor', red_dark,  'FaceAlpha', 0.45);

% Kolmogorov–Smirnov test statistic
[~, ~, ksD] = kstest2(x, y);

% Keep your title (D)
title(sprintf('D = %.3f', ksD), 'FontSize', 16);

box on; grid off;

ax = gca;
xlim([yMin yMax]);
ax.XTick = linspace(yMin, yMax, 3);

ylim([0, 0.2]);
ax.YTick = [0 0.1 0.2];

ax.XTickLabel = [];
ax.YTickLabel = [];
ax.YRuler.SecondaryLabel.Visible = 'off';
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;

ax.LineWidth = 2;
ax.FontSize  = 37;
set(gca,'Position',pos);

end
