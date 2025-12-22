function vis = bfs(A, c)
% BFS finds nodes reachable from the starting node c
% - For undirected (symmetric) networks: returns the weakly connected component
% - For directed (non-symmetric) networks: returns the strongly connected component
%
% Input:
%   A : adjacency matrix (N×N), directed or undirected
%   c : starting node index
%
% Output:
%   vis : set of nodes belonging to the connected component of node c

if ~issymmetric(A)
    % ---- Directed network: find the strongly connected component ----
    At = A';   % Transposed adjacency matrix (used to explore incoming edges)

    % ===== Forward BFS (outgoing edges) =====
    vis_fwd = c;     % visited nodes (initially the starting node)
    new = c;         % frontier of nodes to expand
    while ~isempty(new)
        tem = [];
        for i = 1:length(new)
            % Find all neighbors reachable by outgoing edges
            tem0 = find(A(new(i), :) ~= 0);
            tem = union(tem, tem0);
        end
        % Exclude already visited nodes
        new = setdiff(tem, vis_fwd);
        % Update visited set
        vis_fwd = union(vis_fwd, new);
    end

    % ===== Backward BFS (incoming edges) =====
    vis_bwd = c;     % visited nodes
    new = c;         % frontier
    while ~isempty(new)
        tem = [];
        for i = 1:length(new)
            % On the transposed graph: find nodes that can reach new(i)
            tem0 = find(At(new(i), :) ~= 0);
            tem = union(tem, tem0);
        end
        % Exclude already visited nodes
        new = setdiff(tem, vis_bwd);
        % Update visited set
        vis_bwd = union(vis_bwd, new);
    end

    % ===== Strongly connected component =====
    % Intersection of forward- and backward-reachable sets
    vis = intersect(vis_fwd, vis_bwd);
    return;
end

% ---- Undirected network: standard BFS (weakly connected component) ----
vis = c;       % visited nodes
new = c;       % frontier
while ~isempty(new)
    tem = [];
    for i = 1:length(new)
        % Find all neighbors of current node
        tem0 = find(A(new(i), :) ~= 0);
        tem = union(tem, tem0);
    end
    % Exclude already visited nodes
    new = setdiff(tem, vis);
    % Update visited set
    vis = union(vis, new);
end
