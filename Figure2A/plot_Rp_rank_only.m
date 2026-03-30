function plot_Rp_three_indicators()

% =========================
% data folders
% =========================
baseFolder = 'F:\SI\FunctionA\compute dataA';

folderNames = { ...
    '2.Epidemics (SIS)_MIT Reality Mining_perturbation_type2-0', ...
    '2.Epidemics (SIS)_MIT Reality Mining_perturbation_type2-0.3'};

pLabels = {'$p=0$','$p=0.6$'};

% =========================
% styles
% =========================
top_color = [0 0 0];
lineStyles = {'--',':'};

% =========================
% figure
% =========================
fig = figure('Color','w');
fig.Units = 'centimeters';
fig.Position = [2 2 16 16];

fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 12 12];
fig.PaperSize = [12 12];

% =========================
% top axes: rank(R_p)/n
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
    'XMinorTick','off', ...
    'Layer','top', ...
    'Box','on');

ax1.Units = 'normalized';
ax1.Position = [0.20 0.72 0.74 0.24];
ylim(ax1,[-0.05 1.05]);
ax1.YTick = [0 0.5 1.0];

% =========================
% middle axes: det(R_p)
% =========================
ax2 = axes(fig);
hold(ax2,'on');

set(ax2, ...
    'XScale','log', ...
    'FontSize',25, ...
    'FontName','Times New Roman', ...
    'LineWidth',2.0, ...
    'TickDir','in', ...
    'TickLength',[0.01 0.01], ...
    'XMinorTick','off', ...
    'Layer','top', ...
    'Box','on');

ax2.Units = 'normalized';
ax2.Position = [0.20 0.44 0.74 0.24];
ylim(ax2,[-0.05 1.05]);
ax2.YTick = [0 0.5 1.0];
% =========================
% bottom axes: exp(H)/n
% =========================
ax3 = axes(fig);
hold(ax3,'on');

set(ax3, ...
    'XScale','log', ...
    'FontSize',25, ...
    'FontName','Times New Roman', ...
    'LineWidth',2.0, ...
    'TickDir','in', ...
    'TickLength',[0.01 0.01], ...
    'XMinorTick','off', ...
    'Layer','top', ...
    'Box','on');

ax3.Units = 'normalized';
ax3.Position = [0.20 0.16 0.74 0.24];
ylim(ax3,[-0.05 1.05]);
ax3.YTick = [0 0.5 1.0];


legendHandles = gobjects(1, numel(folderNames));

for i = 1:numel(folderNames)

    folder = fullfile(baseFolder, folderNames{i});
    load(fullfile(folder,'R_p.mat'),'R_p');

    [N, ~, numPerturb] = size(R_p);

xVals = [0.01, 0.1:0.1:1, 2:1:1000];

 rank_Rp  = zeros(1,numPerturb);
det_Rp   = zeros(1,numPerturb);
erank_Rp = zeros(1,numPerturb);

for k = 1:numPerturb
    Rp = R_p(:,:,k);

    rank_Rp(k) = rank(Rp)/N;
    det_Rp(k)  = det(Rp);

    s = svd(Rp);
    ssum = sum(s);

    if ssum > 0
        q = s / ssum;
        q = q(q > eps);
        H = -sum(q .* log(q));
        erank_Rp(k) = exp(H)/N;
    else
        erank_Rp(k) = 0;
    end
end


    % plot
    legendHandles(i) = plot(ax1, xVals, rank_Rp, ...
        'Color', top_color, ...
        'LineStyle', lineStyles{i}, ...
        'LineWidth', 2.1);

    plot(ax2, xVals, det_Rp, ...
        'Color', top_color, ...
        'LineStyle', lineStyles{i}, ...
        'LineWidth', 2.1);

    plot(ax3, xVals, erank_Rp, ...
        'Color', top_color, ...
        'LineStyle', lineStyles{i}, ...
        'LineWidth', 2.1);
end

% =========================
% shared x-axis
% =========================
linkaxes([ax1 ax2 ax3],'x');

xlim(ax1,[0.01 1000]);
xlim(ax2,[0.01 1000]);
xlim(ax3,[0.01 1000]);

ax1.XTick = [0.01 0.1 1 10 100 1000];
ax2.XTick = ax1.XTick;
ax3.XTick = ax1.XTick;

ax1.XTickLabel = [];
ax2.XTickLabel = [];

% =========================
% labels
% =========================
ylabel(ax1, '$\mathrm{rank}(R_p)/n$', ...
    'FontSize',25, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex');

ylabel(ax2, '$\det(R_p)$', ...
    'FontSize',25, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex');

ylabel(ax3, '$\exp(H)/n$', ...
    'FontSize',25, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex');

xlabel(ax3, 'Time', ...
    'FontSize',25, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex');

% =========================
% legend
% =========================
lg = legend(ax1, legendHandles, pLabels, ...
    'Location', 'southwest', ...
    'FontSize', 13, ...
    'FontName', 'Times New Roman', ...
    'Interpreter', 'latex', ...
    'Box', 'off');

lg.ItemTokenSize = [30 10];

end