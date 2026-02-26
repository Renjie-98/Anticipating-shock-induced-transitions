function plot_obs_vs_sim()
% ============================================================
%  plot_obs_vs_sim · Compare observed vs simulated fish data
% ------------------------------------------------------------
%  Uses average node state (mean redundancy per species) and shows:
%   (1) Time series
%   (2) Scatter correlation (Spearman & Pearson)
%   (3) Distribution comparison (K–S test)
%
%  REQUIRED FILES (in current folder):
%    - X_obs.mat  
%    - X_p.mat   
%  REQUIRED CSV:
%    - network state.csv (column: Date)
% ============================================================

%% ====== Load data ======
Sobs = load('X_obs.mat','X_obs');
Sp   = load('X_p.mat','X_p');

A  = squeeze(Sobs.X_obs);
B  = squeeze(Sp.X_p);

yA = mean(A,2);      % observed average node state
yB = mean(B,2);      % predicted average node state

%yA = sum(A,2) ./ max(sum(A~=0,2),1);
%yB = sum(B,2) ./ max(sum(B~=0,2),1);

yA = yA(:); 
yB = yB(:);

%% ====== Load dates from CSV ======
dataDir   = 'C:\Users\xuren\Desktop\NP-real\0Data\11.Ecosystem_fish';
stateFile = fullfile(dataDir,'network state.csv');
T = readtable(stateFile,'TextType','string');
dates = datetime(T.Date,'InputFormat','yyyy/MM/dd');
dates = dates(:);

% Safety: align lengths
n = min([numel(dates), numel(yA), numel(yB)]);
dates = dates(1:n);
yA    = yA(1:n);
yB    = yB(1:n);

%% ====== Common style ======
set(groot,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',14);

blue_dark  = [0.10 0.30 0.90];
blue_light = [0.70 0.82 1.00];
red_dark   = [0.85 0.20 0.20];
red_light  = [1.00 0.78 0.78];
fillAlpha  = 0.40;
cSca       = [0.55 0.20 0.70];

figW = 12; figH = 9;                 % cm
pos  = [0.15 0.15 0.75 0.75];         % unify axis size

%% ---------- (1) Time series ----------
figure('Units','centimeters','Position',[2 2 figW figH]); hold on

plot(dates, yA, '-', 'Color', blue_dark, 'LineWidth', 2.5);
scatter(dates, yA, 70, 'o', ...
    'MarkerEdgeColor', blue_dark, 'MarkerFaceColor', blue_light, ...
    'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

plot(dates, yB, '-', 'Color', red_dark, 'LineWidth', 2.8);
scatter(dates, yB, 70, '^', ...
    'MarkerEdgeColor', red_dark, 'MarkerFaceColor', red_light, ...
    'MarkerEdgeAlpha', 1, 'MarkerFaceAlpha', fillAlpha);

% Legend dummy handles (optional to display legend)
hLegObs = plot(nan,nan,'-o','Color',blue_dark, ...
    'MarkerEdgeColor',blue_dark,'MarkerFaceColor',blue_light, ...
    'LineWidth',2.5,'MarkerSize',6);
hLegSim = plot(nan,nan,'-^','Color',red_dark, ...
    'MarkerEdgeColor',red_dark,'MarkerFaceColor',red_light, ...
    'LineWidth',2.8,'MarkerSize',7);

lgd = legend([hLegObs,hLegSim], {'Observed results','Predicted results'}, ...
    'Location','best','FontSize',9);
lgd.Box = 'off';

% legend off;

box on; grid off;
xlim([dates(1) dates(end)]);

ax = gca;
ax.XTick = linspace(dates(1), dates(end), 6);
ax.XAxis.TickLabelFormat = 'yyyy';

ylim([0 50]);                 % keep your original range
ax.YTick = linspace(0, 50, 6);

ax.XTickLabel = [];
%ax.YTickLabel = [];
ax.YRuler.SecondaryLabel.Visible = 'off';
ax.YAxis.Exponent = 0;

ax.LineWidth = 2;
ax.FontSize  = 30;
set(gca,'Position',pos);

%% ---------- (2) Scatter: Spearman & Pearson ----------
idx = (yA > 0) & (yB > 0);
x = yA(idx);
y = yB(idx);

[rhoS,~] = corr(x,y,'Type','Spearman');
[rhoP,~] = corr(x,y,'Type','Pearson');

xyMax = 1.05 * max([x; y]);
xyMax = ceil(xyMax/10)*10;     % round to nearest 10

figure('Units','centimeters','Position',[2 2 figW figH]); hold on
scatter(x, y, 65, cSca, 'filled', ...
    'MarkerEdgeColor','k', 'MarkerFaceAlpha',0.75);
plot([0 xyMax],[0 xyMax],'k--','LineWidth',1.0);

 title(sprintf('\\bf%c = %.3f,  r = %.3f', 961, rhoS, rhoP), 'FontSize', 25);

axis equal;
xlim([0 xyMax]); ylim([0 xyMax]);
box on; grid off;

ax = gca;
ax.XTick = linspace(0, xyMax, 3);
ax.YTick = linspace(0, xyMax, 3);

ax.XTickLabel = [];
ax.YTickLabel = [];
ax.YRuler.SecondaryLabel.Visible = 'off';
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;

ax.LineWidth = 2;
ax.FontSize  = 37;
set(gca,'Position',pos);

%% ---------- (3) Distribution: KS test ----------
[~,~,ksD] = kstest2(x,y);

figure('Units','centimeters','Position',[2 2 figW figH]); hold on
edges = linspace(min([x; y]), max([x; y]), 25);

histogram(x, edges, 'Normalization','probability', ...
    'FaceColor', blue_dark, 'FaceAlpha', 0.45);
histogram(y, edges, 'Normalization','probability', ...
    'FaceColor', red_dark,  'FaceAlpha', 0.45);

 title(sprintf('\\bfD = %.3f', ksD), 'FontSize', 16);

box on; grid off;
legend off;

xMax = ceil(max([x; y]) / 10) * 10;
xlim([0 xMax]);
ylim([0 0.6]);

ax = gca;
ax.XTick = linspace(0, xMax, 3);
ax.YTick = linspace(0, 0.6, 3);

ax.XTickLabel = [];
ax.YTickLabel = [];
ax.YRuler.SecondaryLabel.Visible = 'off';
ax.XAxis.Exponent = 0;
ax.YAxis.Exponent = 0;

ax.LineWidth = 2;
ax.FontSize  = 37;
set(gca,'Position',pos);

end
