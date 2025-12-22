function plot_observed_vs_predicted()
% ============================================================
%  plot_observed_vs_predicted · Single fixed-format figure
% ------------------------------------------------------------
%  • Output figure size fixed to 12×12 cm
%  • Axes position fixed (aligned across figures)
%  • X/Y axis limits and ticks fixed for consistent comparison
% ============================================================

    % ===== Step 1: Input data =====
    obsVar = input('Enter the name of observed data variable: ', 's');
    predVar = input('Enter the name of predicted data variable: ', 's');
    obsData = evalin('base', obsVar);
    predData = evalin('base', predVar);

    if ~isequal(size(obsData), size(predData))
        error('Observed and predicted data dimensions do not match.');
    end

    [numExps, numPerturb, ~] = size(obsData);
    fprintf('Data size: %d experiments × %d perturbations × %d nodes\n', ...
            numExps, numPerturb, size(obsData,3));

    % ===== Step 2: Compute mean curves =====
    % Compute experiment-wise means (ignoring zeros)
    valid_obs = obsData ~= 0;
    obsMeanExp = sum(obsData .* valid_obs, 3) ./ max(sum(valid_obs, 3), 1);
    %obsMeanExp = mean(obsData, 3);

    obsMean = mean(obsMeanExp, 1);

    valid_pred = predData ~= 0;
    predMeanExp = sum(predData .* valid_pred, 3) ./ max(sum(valid_pred, 3), 1);
    predMean = mean(predMeanExp, 1);

    xVals = linspace(0,1,numPerturb);

    % ===== Step 3: Fix figure size =====
    fig = figure('Color','w');
    fig.Units = 'centimeters';
    fig.Position = [2 2 12 12];   % Figure size: 12×12 cm
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 12 12];
    fig.PaperSize = [12 12];

    ax = axes(fig); hold(ax,'on');

    % ===== Step 4: Define color scheme =====
    blue_light = [0.70 0.85 1.00];
    blue_dark  = [0.00 0.45 0.74];
    red_light  = [1.00 0.75 0.75];
    red_dark   = [0.70 0.00 0.00];

    % ===== Step 5: Plot individual experiment curves =====
    for i = 1:numExps
        plot(ax, xVals, obsMeanExp(i,:), 'Color', [blue_light 0.4], 'LineWidth', 1.2);
        plot(ax, xVals, predMeanExp(i,:), 'Color', [red_light 0.4], 'LineWidth', 1.2);
    end

    % ===== Step 6: Plot mean curves =====
    h1 = plot(ax, xVals, obsMean, '-', 'Color', blue_dark, 'LineWidth', 2.5);
    scatter(ax, xVals, obsMean, 60, 'MarkerEdgeColor', blue_dark, ...
        'MarkerFaceColor', blue_light, 'LineWidth', 1);

    h2 = plot(ax, xVals, predMean, '-', 'Color', red_dark, 'LineWidth', 2.8);
    s = scatter(ax, xVals, predMean, 60, 'MarkerEdgeColor', red_dark, ...
        'MarkerFaceColor', red_light, 'LineWidth', 1);
    s.MarkerFaceAlpha = 0.4;

    % ===== Step 7: Format axes =====
    set(ax, 'FontSize', 25, 'FontName','Times New Roman', 'LineWidth', 2, ...
        'TickDir','in', 'TickLength',[0.015 0.015]);

    % Fix X-axis range and ticks
    xlim(ax,[0 1]);
    xticks(ax,[0 0.5 1]);
    xticklabels(ax,{'0','0.5','1.0'});

    % Fix Y-axis range and ticks (adjust manually for alignment)
    ylimRange = [-5 15];  % M
    %ylimRange = [-0.2 1]; % E
    %ylimRange = [-0.1 1.5]; % G 
    %ylimRange = [-1 9];  % P 
    %ylimRange = [-40 80];  % S1
    %ylimRange = [-80 80];  % S2
    %ylimRange = [-10 14];  % S3
    %ylimRange = [-0.2 1];  % NV1,2
    %ylimRange = [0.10 0.22];  % NV3
    %ylimRange = [-2 10];  % N
    %ylimRange = [-1 1];  % B

    % ===== Step 7b: Auto-detect good Y-axis range =====
ymin = min([obsMean(:); predMean(:)]);
ymax = max([obsMean(:); predMean(:)]);

% Add padding
padding = 0.05*(ymax - ymin + eps);
ylimRange = [ymin - padding, ymax + padding];
    ax.YTick = linspace(ylimRange(1), ylimRange(2), 5);
    ax.YTickLabel = arrayfun(@(y) sprintf('%g', y), ax.YTick,'UniformOutput',false);
    axis(ax,'square');
    ax.Layer = 'top';
    box(ax,'on');
    
    % ===== Step 8: Fix axes position =====
    ax.Units = 'normalized';
    ax.Position = [0.22 0.20 0.65 0.65];

    % ===== Step 9: Add legend =====
    legend(ax, [h1, h2], {'Observed results', 'Predicted results'}, ...
        'Location', 'northeast', ...
        'FontSize', 25, ...
        'Box', 'off', ...
        'TextColor', 'k');

    hold(ax,'off');
end
