function plot_multi()

% =========================
% data folders
% =========================
baseFolder = 'F:\SI\FunctionA\compute dataA';

folderNames = { ...
    '6.Population_Little Rock Lake_perturbation_type3-0', ...
    '6.Population_Little Rock Lake_perturbation_type3-0.3', ...
    '6.Population_Little Rock Lake_perturbation_type3-0.6'};
pLabels = {'$p=0$','$p=0.3$','$p=0.6$'};


blue = [0.00 0.45 0.74];
red  = [0.75 0.00 0.00];
orange = [0.85 0.33 0.10];
green = [0.00 0.60 0.30];
top_color = [0 0 0];

% line styles represent p
lineStyles = {'-','--',':'};

% =========================
% figure
fig = figure('Color','w');
fig.Units = 'centimeters';
fig.Position = [2 2 16 16];

fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 12 12];
fig.PaperSize = [12 12];

% =========================
% bottom axes
% =========================
ax1 = axes(fig);
hold(ax1,'on');

set(ax1, ...
    'XScale','log', ...
    'FontSize',25, ...
    'FontName','Times New Roman', ...
    'LineWidth',2.0, ...
    'TickDir','in', ...
    'TickLength',[0.01 0.01], ...
    'XMinorTick','on', ...
    'Layer','top', ...
    'Box','on');

ax1.Units = 'normalized';
ax1.Position = [0.12 0.12 0.83 0.43];
%ylim(ax1,[0 1.0]);
%ax1.YTick = [0 0.5 1.0];

ylim(ax1,[0 10]);
ax1.YTick = [0 5 10];
%ylim(ax1,[0 0.6]);
%ax1.YTick = [0 0.3 0.6];

% top axes
ax2 = axes(fig);
hold(ax2,'on');

set(ax2, ...
    'XScale','log', ...
    'YScale','log', ...  
    'FontSize',25, ...
    'FontName','Times New Roman', ...
    'LineWidth',2.0, ...
    'TickDir','in', ...
    'TickLength',[0.01 0.01], ...
    'XMinorTick','on', ...
    'Layer','top', ...
    'Box','on');

ax2.Units = 'normalized';
ax2.Position = [0.12 0.55 0.83 0.43];
ylim(ax2,[10^(-2.4) 10^(0.4)]);
ax2.YTick = [1e-2 1e-1 1];
% =========================
% legend handles
% =========================
legendHandles_top = gobjects(1, 2*numel(folderNames));
legendHandles_bottom = gobjects(1, 2*numel(folderNames));
legendLabels_bottom = cell(1, 2*numel(folderNames));

for i = 1:numel(folderNames)
    folder = fullfile(baseFolder, folderNames{i});
    load(fullfile(folder,'R_p.mat'),'R_p');
    load(fullfile(folder,'X_p.mat'),'X_p');
    load(fullfile(folder,'X_test.mat'),'X_test');
    % remove unperturbed initial state
    X_test(:,1,:) = [];

    [~, numPerturb, ~] = size(X_p);
    % mean curves
    xpreMean = squeeze(mean(mean(X_p,3),1));
    xobsMean = squeeze(mean(mean(X_test,3),1));

  
    % x-axis

%tspan = [0.01:0.01:0.1, 0.11:0.1:1, 2:1000];
%t_star  = 5.5;
%t2 = linspace(5.5, 550, 500);
%tspan = [0, logspace(-5, log10(5.5), 1500), t2(2:end)];

%t_star  = 0.3;
%t2 = linspace(0.3, 30, 500);
%tspan = [0, logspace(-5, log10(0.3), 1500), t2(2:end)];

t_star  = 1.4;
t2 = linspace(1.4, 140, 500);
tspan = [0, logspace(-5, log10(1.4), 1500), t2(2:end)];
 xVals = tspan/t_star;

f_minus = 0.05;
f_plus  = 0.2;

t_minus = f_minus * t_star;
t_plus  = f_plus  * t_star;

[~, idx_star]  = min(abs(xVals - t_star));
[~, idx_minus] = min(abs(xVals - t_minus));
[~, idx_plus]  = min(abs(xVals - t_plus));

t_star_plot  = xVals(idx_star)/t_star;
t_minus_plot = xVals(idx_minus)/t_star;
t_plus_plot  = xVals(idx_plus)/t_star;

xline(ax1, t_minus_plot, ':',  'Color', [0 0 0], 'LineWidth', 1.5);
xline(ax1, t_star_plot,  '-',  'Color', [0 0 0], 'LineWidth', 1.8);
xline(ax1, t_plus_plot,  '--', 'Color', [0 0 0], 'LineWidth', 1.5);

xline(ax2, t_minus_plot, ':',  'Color', [0 0 0], 'LineWidth', 1.5);
xline(ax2, t_star_plot,  '-',  'Color', [0 0 0], 'LineWidth', 1.8);
xline(ax2, t_plus_plot,  '--', 'Color', [0 0 0], 'LineWidth', 1.5);
yl = ylim(ax2);
ypos = yl(1) * 1.1;   

text(ax2, t_minus_plot*1.4, ypos, '$\frac{t^{-}}{t^{*}}$', ...
    'Interpreter','latex', ...
    'FontSize',18, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom');

text(ax2, t_star_plot*1.4, ypos, '$\frac{t^{*}}{t^{*}}$', ...
    'Interpreter','latex', ...
    'FontSize',18, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom');

text(ax2, t_plus_plot*1.4, ypos, '$\frac{t^{+}}{t^{*}}$', ...
    'Interpreter','latex', ...
    'FontSize',18, ...
    'HorizontalAlignment','center', ...
    'VerticalAlignment','bottom');
% normalized rank and effective rank
    N = size(R_p,1);
    rank_Rp  = zeros(1, numPerturb);
    erank_Rp = zeros(1, numPerturb);

  for k = 1:numPerturb
    Rp = R_p(:,:,k);
    % normalized rank
    rank_Rp(k) = rank(Rp) / N;
    % effective rank
    s = svd(Rp);
    ssum = sum(s);
    if ssum > 0
        q = s / ssum;
        q = q(q > eps);
        H = -sum(q .* log(q));
        erank_Rp(k) = exp(H) / N;
    else
        erank_Rp(k) = 0;
    end
  end
  
markerTypes = {'s','p','v'};
    % marker positions
xmin = 1e-2;     % normalized x-axis
xmax = 1e2;

% 最左边可见点索引
idx_left = find(xVals >= xmin, 1, 'first');

% bottom panel markers
markerX = [xVals(idx_left), 1e-1, 1e0, 1e1, 1e2];   % 第一个强制最左开始
markerIdx = zeros(size(markerX));
for ii = 1:numel(markerX)
    [~, markerIdx(ii)] = min(abs(xVals - markerX(ii)));
end
markerIdx = unique(markerIdx, 'stable');

% top panel markers
markerX_top = logspace(log10(xmin), log10(xmax), 24);
markerIdx_top = zeros(size(markerX_top));
for ii = 1:numel(markerX_top)
    [~, markerIdx_top(ii)] = min(abs(xVals - markerX_top(ii)));
end
markerIdx_top = unique([idx_left, markerIdx_top]); 
% =========================
    % bottom panel
    % =========================
    hObs = plot(ax1, xVals, xobsMean, ...
        'Color', blue, ...
        'LineStyle', lineStyles{i}, ...
        'LineWidth', 2.35, ...
        'Marker', 'o', ...
        'MarkerIndices', markerIdx, ...
        'MarkerSize', 5.0, ...
        'MarkerFaceColor', blue, ...
        'MarkerEdgeColor', blue);

    hPre = plot(ax1, xVals, xpreMean, ...
        'Color', red, ...
        'LineStyle', lineStyles{i}, ...
        'LineWidth', 2.35, ...
        'Marker', '^', ...
        'MarkerIndices', markerIdx, ...
        'MarkerSize', 5.4, ...
        'MarkerFaceColor', red, ...
        'MarkerEdgeColor', red);

    legendHandles_bottom(2*i-1) = hObs;
    legendHandles_bottom(2*i)   = hPre;

    legendLabels_bottom{2*i-1} = ['Observed results, ', pLabels{i}];
    legendLabels_bottom{2*i}   = ['Predicted results, ', pLabels{i}];

    % =========================
    % top panel
    % =========================
    rank_plot  = max(rank_Rp,  1e-2);
    erank_plot = max(erank_Rp, 1e-2);
hRank = plot(ax2, xVals, rank_plot, ...
    'Color', orange, ...
    'LineStyle','-', ...
    'Marker', markerTypes{i}, ...
    'MarkerIndices', markerIdx_top, ...
    'MarkerFaceColor','none', ...
    'MarkerEdgeColor', orange, ...
    'MarkerSize', 7, ...
    'LineWidth', 1.5);

hErank = plot(ax2, xVals, erank_plot, ...
    'Color', green, ...
    'LineStyle','-', ...
    'Marker', markerTypes{i}, ...
    'MarkerIndices', markerIdx_top, ...
    'MarkerFaceColor','none', ...
    'MarkerEdgeColor', green, ...
    'MarkerSize', 7, ...
    'LineWidth', 1.5);
% legend handles（两条线都要存）
    legendHandles_top(2*i-1) = hRank;
    legendHandles_top(2*i)   = hErank;
end

% =========================
% shared x-axis
% =========================
   linkaxes([ax1 ax2],'x');
xlim([0.055/t_star 550/t_star])

xlim(ax1, [0.01*t_star/t_star 100*t_star/t_star]);
xlim(ax2, [0.01*t_star/t_star 100*t_star/t_star]);

ax1.XTick = [0.01*t_star 0.1*t_star t_star 10*t_star 100*t_star] /t_star;
ax1.XTick = [0.01*t_star 0.1*t_star t_star 10*t_star 100*t_star] /t_star;

ax2.XTickLabel = [];

% =========================
% bottom legend
% =========================
lg1 = legend(ax1, legendHandles_bottom, legendLabels_bottom, ...
    'Location', 'northwest', ...
    'FontSize', 13, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex', ...
    'Box', 'off');
%'northwest'
lg1.ItemTokenSize = [29 10];

legend(ax1,'off');
set(ax1, 'XMinorTick', 'off')
% =========================
% top legend
% =========================
legendLabels_top = cell(1, 2*numel(folderNames));
for i = 1:numel(folderNames)
    legendLabels_top{2*i-1} = ['rank, ', pLabels{i}];
    legendLabels_top{2*i}   = ['e-rank, ', pLabels{i}];
end

lg2 = legend(ax2, legendHandles_top, legendLabels_top, ...
    'Location', 'southwest', ...
    'FontSize', 13, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex', ...
    'Box', 'off');
lg2.ItemTokenSize =[30 10];
lg2.Position(2) = lg2.Position(2) + 0.02;
set(ax2, 'XMinorTick', 'off')

ax1.YMinorTick = 'off';
ax2.YMinorTick = 'off';
legend off;


end