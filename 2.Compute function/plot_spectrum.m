function plot_spectrum()
% ============================================================
%  plot_spectrum (single-figure version, improved)
% ------------------------------------------------------------
%  • Traverse all *_Rp.mat files in the current directory
%  • Compute spectral metrics (ME, MSE, Var, RCLE) for each file
%  • Generate one 12×12 cm figure per file and save it
%  • The first figure shows the legend; others do not
%  • Each curve is automatically assigned a different marker
%  • Output file names correspond to the original .mat files
% ============================================================

% ---- Find all Rp files ----
files = dir('*_Rp.mat');
if isempty(files)
    error('❌ No *_Rp.mat files found in the current folder.');
end
fprintf('Found %d Rp files in current folder.\n', numel(files));

% ---- Color palette ----
colors = [
    91 132 215;   % ME
    227 155 108;  % MSE
    127 201 155;  % Var
    217 122 135   % RCLE
] / 255;
momentTitles = {'ME','MSE','Var','RCLE'};
markers = {'o','s','^','d'};  % Different markers

for k = 1:numel(files)
    matFile = files(k).name;
    fprintf('\n=== Processing %s ===\n', matFile);

    % Load data
    S = load(matFile);
    if ~isfield(S,'R_p')
        warning('File %s does not contain R_p. Skipped.', matFile);
        continue;
    end
    R_p = S.R_p;

    % Compute spectral metrics
    nSteps = size(R_p,3);
    mu1 = zeros(1,nSteps); 
    mu2 = mu1; 
    varSpec = mu1; 
    lambdaMax = mu1;

    for t = 1:nSteps
        eVals = eig(R_p(:,:,t));
        mu1(t) = mean(eVals);
        mu2(t) = mean(eVals.^2);
        varSpec(t) = mu2(t) - mu1(t)^2;
        lambdaMax(t) = max(abs(eVals));
    end

    lambdaChange = [0, diff(lambdaMax)./lambdaMax(1:end-1)];
    xVals = linspace(0,1,nSteps);
    yData = {mu1, mu2, varSpec, lambdaChange};

    % ---- Create individual figure ----
    fig = figure('Color','w');
    fig.Units = 'centimeters';
    fig.Position = [2 2 12 12];    % Fixed 12×12 cm
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 12 12];
    fig.PaperSize = [12 12];

    hold on;
    for i = 1:4
        plot(xVals, yData{i}, '-', 'Color', colors(i,:), ...
            'LineWidth', 2.5, ...
            'Marker', markers{i}, 'MarkerSize',6, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', colors(i,:));
    end

    ylim([-1 2]); 
    xlim([0 1]);
    set(gca,'FontSize',16,'FontName','Times New Roman','LineWidth',2,'TickDir','in');
    axis square; 
    box on;

    % Configure Y-axis with 5 ticks and hide labels
    ax = gca;
    ax.YTick = linspace(-1,2,5);
    ax.YTickLabel = [];
    
    % Configure X-axis ticks and hide labels
    ax.XTick = linspace(0,1,3);
    ax.XTickLabel = [];

    % Only show legend in the first figure
    if k == 6
        legend(momentTitles,'Location','best','FontSize',24,'Box','off');
    end

    title(strrep(matFile,'_','\_'),'FontSize',12);

    % ---- Save figure (file name matches mat file) ----
    saveName = fullfile(pwd, [matFile(1:end-4) '_spectrum.png']);
    print(fig, saveName, '-dpng', '-r300');
    fprintf('✅ Saved: %s\n', saveName);

end

end
