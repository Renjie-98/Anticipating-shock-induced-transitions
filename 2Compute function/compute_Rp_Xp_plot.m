function allResults = compute_Rp_Xp_plot_all()
% COMPUTE_RP_XP_PLOT_ALL
% Batch process three perturbation cases:
%   1. Node loss
%   2. Link loss
%   3. Weight loss
%
% For each case:
%   - Estimate R_p
%   - Predict X_p
%   - Plot observed vs predicted states
%   - Compute relative error
%
% Finally:
%   - Plot relative errors of all three cases in one figure with 95% CI.

    %% ================= 1. Base path =================
    basePath = 'F:\NP-real\1Coding\1Main function\compute data';

    %% ================= 2. Define cases =================
    cases = struct([]);

    cases(1).folder = fullfile(basePath, ...
        '0.Mutualistic_Coral Reefs_perturbation_type1_test');
    cases(1).label = 'Node loss';
    cases(1).ylimRange = [0 0.4];     % NV1 / NV3

    cases(2).folder = fullfile(basePath, ...
        '0.Mutualistic_Coral Reefs_perturbation_type2_test');
    cases(2).label = 'Link loss';
    cases(2).ylimRange = [0 16];      % Mutualistic system, adjust if needed

    cases(3).folder = fullfile(basePath, ...
        '0.Mutualistic_Coral Reefs_perturbation_type2_test');
    cases(3).label = 'Weight loss';
    cases(3).ylimRange = [0 16];      % Mutualistic system, adjust if needed

    %% ================= 3. Process all cases =================
    allResults = struct([]);

    for k = 1:numel(cases)
        fprintf('\n========================================\n');
        fprintf('Processing case %d/%d: %s\n', k, numel(cases), cases(k).label);
        fprintf('Folder: %s\n', cases(k).folder);
        fprintf('========================================\n');

        result = process_one_case(cases(k).folder, cases(k).label, cases(k).ylimRange);

        allResults(k).label = cases(k).label;
        allResults(k).folder = cases(k).folder;
        allResults(k).xVals = result.xVals;
        allResults(k).relative_error = result.relative_error;
        allResults(k).relMeanExp = result.relMeanExp;
    end

    save(fullfile(basePath, 'all_relative_error_results.mat'), 'allResults');
    fprintf('\nAll relative error results have been saved.\n');

    %% ================= 4. Plot all relative errors in one figure =================
    plot_relative_error_all(basePath, allResults);

    fprintf('\nFinished all cases successfully.\n');
end


%% ============================================================
% Process one perturbation case
% ============================================================
function result = process_one_case(folderPath, caseLabel, ylimRange)

    safeLabel = make_safe_filename(caseLabel);

    %% ================= 1. Load training data =================
    files = dir(fullfile(folderPath, 'x0*.mat'));
    M = numel(files);

    fprintf('Found %d training files.\n', M);

    if M == 0
        error('No training files were found in %s. Please check file pattern x0*.mat.', folderPath);
    end

    [~, idx] = sort({files.name});
    files = files(idx);

    %% Load first file to get dimensions
    tmp = load(fullfile(folderPath, files(1).name), 'outputs', 'x0');

    if ~isfield(tmp, 'outputs') || ~isfield(tmp, 'x0')
        error('The first training file does not contain outputs or x0.');
    end

    [~, P, N] = size(tmp.outputs);

    fprintf('Number of perturbations P = %d\n', P);
    fprintf('Number of nodes N = %d\n', N);

    X0   = zeros(M, N);
    Xbar = zeros(M, P, N);

    for i = 1:M
        D = load(fullfile(folderPath, files(i).name), 'outputs', 'x0');

        if ~isfield(D, 'outputs') || ~isfield(D, 'x0')
            error('File %s does not contain outputs or x0.', files(i).name);
        end

        X0(i,:) = D.x0(:).';
        Xbar(i,:,:) = mean(D.outputs, 1);
    end

    %% ================= 2. Compute C00 =================
    C00 = zeros(N, N);

    for i = 1:M
        x0i = X0(i,:).';
        C00 = C00 + x0i * x0i.';
    end

    C00 = C00 / M;

    C00_inv = pinv_trunc(C00);

    %% ================= 3. Compute response operators R_p =================
    R_p = zeros(N, N, P);

    for p = 1:P
        Xp = squeeze(Xbar(:,p,:));

        Cp0 = zeros(N, N);

        for i = 1:M
            xpi = Xp(i,:).';
            x0i = X0(i,:).';
            Cp0 = Cp0 + xpi * x0i.';
        end

        Cp0 = Cp0 / M;

        Rp = Cp0 * C00_inv;
        R_p(:,:,p) = Rp;
    end

    save(fullfile(folderPath, 'R_p.mat'), 'R_p');
    fprintf('R_p.mat has been saved.\n');

    %% ================= 4. Load testing data X_test.mat =================
    testFile = fullfile(folderPath, 'X_test.mat');

    if ~isfile(testFile)
        error('X_test.mat was not found in %s.', folderPath);
    end

    S = load(testFile);

    if isfield(S, 'X_test')
        data3D = S.X_test;
    else
        varNames = fieldnames(S);
        data3D = S.(varNames{1});
        warning('Variable X_test was not found. Using variable "%s" instead.', varNames{1});
    end

    %% ================= 5. Process testing data for prediction =================
    % Keep the original design:
    %   data3D(:,1,:) = initial state
    %   data3D(:,2,:) = unperturbed steady state
    %   data3D(:,3:end,:) = perturbed steady states
    %
    % Remove the second step before prediction.
    data3D_for_prediction = data3D;
    data3D_for_prediction(:,2,:) = [];

    [numExps, numPerturb, numNodes] = size(data3D_for_prediction);

    if numNodes ~= N
        error('Node number mismatch: training N = %d, testing N = %d.', N, numNodes);
    end

    X0_test = squeeze(data3D_for_prediction(:,1,:));

    %% ================= 6. Predict X_p =================
    X_p = zeros(numExps, numPerturb, numNodes);

    for p = 1:numPerturb
        Rp_current = R_p(:,:,p);
        Xp_current = Rp_current * X0_test.';
        X_p(:,p,:) = Xp_current.';
    end

    save(fullfile(folderPath, 'X_p.mat'), 'X_p');
    fprintf('X_p.mat has been saved.\n');

    %% ================= 7. Prepare observed and predicted data =================
    % Keep original plotting logic:
    % Observed data uses original X_test.
    % Remove the first initial state before plotting.
    obsData = data3D;
    predData = X_p;

    obsData(:,1,:) = [];

    if ~isequal(size(obsData), size(predData))
        error(['Size mismatch in case "%s".\n', ...
               'size(obsData)  = [%s]\n', ...
               'size(predData) = [%s]'], ...
               caseLabel, num2str(size(obsData)), num2str(size(predData)));
    end

    [numExps_plot, numPerturb_plot, ~] = size(obsData);
    xVals = linspace(0, 1, numPerturb_plot);

    %% ================= 8. Plot observed vs predicted =================
    plot_observed_vs_predicted(folderPath, safeLabel, obsData, predData, ylimRange);

    %% ================= 9. Compute relative error =================
    relative_error = abs(predData - obsData) ./ (abs(obsData) + eps);

    relMeanExp = mean(relative_error, 3);
    relMeanExp = reshape(relMeanExp, [numExps_plot, numPerturb_plot]);

    save(fullfile(folderPath, 'relative_error.mat'), ...
         'relative_error', 'relMeanExp', 'xVals');

    fprintf('relative_error.mat has been saved.\n');

    %% ================= 10. Return results =================
    result.xVals = xVals;
    result.relative_error = relative_error;
    result.relMeanExp = relMeanExp;
end


%% ============================================================
% Plot observed vs predicted states for one case
% ============================================================
function plot_observed_vs_predicted(folderPath, safeLabel, obsData, predData, ylimRange)

    [numExps, numPerturb, ~] = size(obsData);

    obsMeanExp = mean(obsData, 3);
    obsMeanExp = reshape(obsMeanExp, [numExps, numPerturb]);

    predMeanExp = mean(predData, 3);
    predMeanExp = reshape(predMeanExp, [numExps, numPerturb]);

    obsMean = mean(obsMeanExp, 1);
    predMean = mean(predMeanExp, 1);

    xVals = linspace(0, 1, numPerturb);

    fig = figure('Color','w');
    fig.Units = 'centimeters';
    fig.Position = [2 2 12 12];
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 12 12];
    fig.PaperSize = [12 12];

    ax = axes(fig);
    hold(ax,'on');

    blue_light = [0.70 0.85 1.00];
    blue_dark  = [0.00 0.45 0.74];
    red_light  = [1.00 0.75 0.75];
    red_dark   = [0.70 0.00 0.00];

    for i = 1:numExps
        plot(ax, xVals, obsMeanExp(i,:), ...
            'Color', blue_light, 'LineWidth', 1.2);

        plot(ax, xVals, predMeanExp(i,:), ...
            'Color', red_light, 'LineWidth', 1.2);
    end

    h1 = plot(ax, xVals, obsMean, '-', ...
        'Color', blue_dark, 'LineWidth', 2.5);

    scatter(ax, xVals, obsMean, 60, ...
        'MarkerEdgeColor', blue_dark, ...
        'MarkerFaceColor', blue_light, ...
        'LineWidth', 1);

    h2 = plot(ax, xVals, predMean, '-', ...
        'Color', red_dark, 'LineWidth', 2.8);

    s = scatter(ax, xVals, predMean, 60, ...
        'MarkerEdgeColor', red_dark, ...
        'MarkerFaceColor', red_light, ...
        'LineWidth', 1);

    s.MarkerFaceAlpha = 0.4;

    set(ax, 'FontSize', 25, ...
        'FontName','Times New Roman', ...
        'LineWidth', 2, ...
        'TickDir','in', ...
        'TickLength',[0.015 0.015]);

    xlim(ax,[0 1]);
    xticks(ax,[0 0.5 1]);
    xticklabels(ax,{'0','0.5','1.0'});

    ylim(ax, ylimRange);

    ax.YTick = linspace(ylimRange(1), ylimRange(2), 5);
    ax.YTickLabel = arrayfun(@(y) sprintf('%g', y), ax.YTick, ...
                             'UniformOutput', false);

    axis(ax,'square');
    ax.Layer = 'top';
    box(ax,'on');

    ax.Units = 'normalized';
    ax.Position = [0.22 0.20 0.65 0.65];

    legend(ax, [h1, h2], {'Observed states', 'Predicted states'}, ...
        'Location', 'northeast', ...
        'FontSize', 20, ...
        'Box', 'off', ...
        'TextColor', 'k');

    ax.XTickLabel = [];
    ax.YTickLabel = [];

    hold(ax,'off');

    saveas(fig, fullfile(folderPath, 'observed_vs_predicted.png'));
    print(fig, fullfile(folderPath, 'observed_vs_predicted.pdf'), '-dpdf', '-painters');

    saveas(fig, fullfile(folderPath, ['observed_vs_predicted_', safeLabel, '.png']));
    print(fig, fullfile(folderPath, ['observed_vs_predicted_', safeLabel, '.pdf']), ...
        '-dpdf', '-painters');

    fprintf('Observed vs predicted figure has been saved.\n');
end


%% ============================================================
% Plot relative errors of all cases in one figure
% ============================================================
function plot_relative_error_all(outputFolder, allResults)

    fig = figure('Color','w');
    fig.Units = 'centimeters';
    fig.Position = [2 2 12 12];
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 12 12];
    fig.PaperSize = [12 12];

    ax = axes(fig);
    hold(ax,'on');

    colors = [
        0.00 0.45 0.74
        0.85 0.33 0.10
        0.47 0.67 0.19
    ];

    hLines = gobjects(numel(allResults), 1);
    legendNames = cell(numel(allResults), 1);

    allY = [];

    for k = 1:numel(allResults)
        xVals = allResults(k).xVals;
        relMeanExp = allResults(k).relMeanExp;

        numExps = size(relMeanExp, 1);

        mu = mean(relMeanExp, 1);
        sigma = std(relMeanExp, 0, 1);
        sem = sigma ./ sqrt(numExps);

        if numExps > 1 && exist('tinv', 'file') == 2
            tval = tinv(0.975, numExps - 1);
        else
            tval = 1.96;
        end

        ci = tval .* sem;

        lower = mu - ci;
        upper = mu + ci;

        lower(lower < 0) = 0;

        c = colors(k,:);

        fill(ax, [xVals fliplr(xVals)], ...
                 [upper fliplr(lower)], ...
                 c, ...
                 'FaceAlpha', 0.18, ...
                 'EdgeColor', 'none', ...
                 'HandleVisibility', 'off');

        hLines(k) = plot(ax, xVals, mu, '-', ...
            'Color', c, ...
            'LineWidth', 2.8);

        scatter(ax, xVals, mu, 55, ...
            'MarkerEdgeColor', c, ...
            'MarkerFaceColor', [1 1 1], ...
            'LineWidth', 1.2, ...
            'HandleVisibility', 'off');

        legendNames{k} = allResults(k).label;

        allY = [allY, lower, upper, mu];
    end

    set(ax, 'FontSize', 25, ...
        'FontName','Times New Roman', ...
        'LineWidth', 2, ...
        'TickDir','in', ...
        'TickLength',[0.015 0.015]);

    xlim(ax,[0 1]);
    xticks(ax,[0 0.5 1]);
    xticklabels(ax,{'0','0.5','1.0'});

    allY = allY(isfinite(allY));

    if isempty(allY)
        ylimRange = [0 1];
    else
        yMax = max(allY);
        if yMax <= 0
            yMax = 1;
        end
        ylimRange = [0, 1.10 * yMax];
    end

    ylim(ax, ylimRange);

    ax.YTick = linspace(ylimRange(1), ylimRange(2), 5);
    ax.YTickLabel = arrayfun(@(y) sprintf('%g', y), ax.YTick, ...
                             'UniformOutput', false);

    axis(ax,'square');
    ax.Layer = 'top';
    box(ax,'on');

    ax.Units = 'normalized';
    ax.Position = [0.22 0.20 0.65 0.65];

    legend(ax, hLines, legendNames, ...
        'Location', 'northeast', ...
        'FontSize', 18, ...
        'Box', 'off', ...
        'TextColor', 'k');

    % Keep the same style as your original figures.
    ax.XTickLabel = [];
    ax.YTickLabel = [];

    hold(ax,'off');

    saveas(fig, fullfile(outputFolder, 'relative_error_all_perturbations.png'));
    print(fig, fullfile(outputFolder, 'relative_error_all_perturbations.pdf'), ...
        '-dpdf', '-painters');

    fprintf('Combined relative error figure has been saved.\n');
end


%% ============================================================
% Truncated SVD pseudoinverse
% ============================================================
function Ainv = pinv_trunc(A)

    relTol = 1e-10;

    [U,S,V] = svd(A,'econ');
    s = diag(S);

    tau = relTol * (max(s) + eps);

    keep = (s > tau);
    r = sum(keep);
    n = min(size(A));

    if r < n
        warning(['Matrix is near-singular: numerical rank = %d < %d. ', ...
                 'Using truncated SVD pseudoinverse. tau = %.3e'], r, n, tau);
        pause(2);
    end

    s_inv = zeros(size(s));
    s_inv(keep) = 1 ./ s(keep);

    Ainv = V * diag(s_inv) * U.';
end


%% ============================================================
% Make safe file name from case label
% ============================================================
function safeName = make_safe_filename(label)

    safeName = lower(label);
    safeName = strrep(safeName, ' ', '_');
    safeName = regexprep(safeName, '[^a-zA-Z0-9_]', '');

end