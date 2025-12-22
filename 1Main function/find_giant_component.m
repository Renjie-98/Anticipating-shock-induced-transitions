function cluster = find_giant_component(A)
% FIND_GAINT_COMPONENT finds the giant component of a network
% - For undirected (symmetric): giant weakly connected component
% - For directed (non-symmetric): giant strongly connected component
%
% Input:
%   A : adjacency matrix (N×N)
% Output:
%   cluster : node indices of the giant component
n = length(A);
unvis = 1:n;
cluster = [];
num = 0;

while any(unvis)
    num = num + 1;
    c = unvis(1);
    vis = bfs(A, c);   % Call the improved BFS

    % Ensure the result is a row vector
    if size(vis,1) ~= 1
        vis = vis';
    end

    % Save: the 1st column is the component size, the rest are node indices
    cluster(num,1:(length(vis)+1)) = [length(vis), vis];
    unvis = setdiff(unvis, vis);
end

% ------------------- Modification here -------------------
if issymmetric(A)
    % Undirected: keep original behavior (largest component)
    [~, idx] = max(cluster(:,1));
    cluster = cluster(idx, 2:end);
else
    % Directed: concatenate all SCCs with size > 1
    idx_gt1 = find(cluster(:,1) > 1);
    cluster0 = [];
    for i = 1:length(idx_gt1)
        nodes = cluster(idx_gt1(i), 2:1+cluster(idx_gt1(i),1));
        cluster0 = [cluster0, nodes];
    end
    if isempty(cluster0)
        % fallback: if no SCC has size > 1, return the largest one
        [~, idx] = max(cluster(:,1));
        cluster = cluster(idx, 2:end);
    else
        cluster = unique(cluster0); % return all nodes in SCCs of size>1
    end
end