% project 5: graphs
% start: 17.12.2024

% https://www.mathworks.com/matlabcentral/answers/15318-gml-files-in-matlab
set(groot, 'defaultTextInterpreter', 'latex');
set(groot, 'defaultLegendInterpreter', 'latex');
set(groot, 'defaultAxesTickLabelInterpreter', 'latex');

S = fileread('dolphins.gml');

nodes = regexp(S, 'node.*?id (?<id>\d+).*?label\s*"(?<label>[^"]*)"', 'names');
edges = regexp(S, 'edge.*?source\s*(?<source>\d+).*?target\s*(?<target>\d+)', 'names');

all_ids = {nodes.id};
all_names = {nodes.label};
all_sources = {edges.source};
all_targets = {edges.target};

[source_found, s] = ismember(all_sources, all_ids);
nfidx = find(~source_found);
if ~isempty(nfidx)
   error('Source ids not found in node list, starting from "%s"', edges(nfidx(1).source));
end
[target_found, t] = ismember(all_targets, all_ids);
nfidx = find(~target_found);
if ~isempty(nfidx)
   error('Target ids not found in node list, starting from "%s"', edges(nfidx(1).target));
end

EdgeTable = table([s.', t.'], ones(length(s),1), 'VariableNames', {'EndNodes' 'Weight'});
NodeTable = table(all_names.', 'VariableNames',{'Name'});
G = graph(EdgeTable,NodeTable);

nNode = length(nodes);
W = sparse(s,t,true,nNode,nNode);
W = W | W';

net = networkvisualizer(W);

% Add labels to nodes
net.setNodeLabels(all_names);
net.setNodeSizes('auto');

% Prepare the figure and plot
figure(1);
set(gcf, 'Position', [0 0 1200 640]);
set(gcf, 'Color', [1 1 1]);
plot(net);
title('Dolphin graph')
movegui('center');

%% Facebook dataset

%files = gunzip('facebook.tar.gz');
%untar('facebook.tar')
edges = readmatrix('facebook/3980.edges', 'FileType','text');
G = graph(edges(:,1), edges(:,2));

egoNode = max(max(edges)) + 1;
numNodes = numnodes(G);
G = addnode(G, 1);

newEdges = [(1:numNodes)' repmat(egoNode, numNodes, 1)];
G = addedge(G, newEdges(:,1), newEdges(:,2));

figure;
plot(G, 'NodeColor', 'k');
title('Graph from Edge List with Ego Node');

G = rmnode(G, egoNode);
numNodes = numnodes(G);

graph_metrics(G,numNodes)


%% 1)
function graph_metrics(G,numNodes)
    node_degrees = degree(G);

    [max_deg,~] = max(node_degrees);
    [degree_counts,degree_edges] = histcounts(node_degrees, 0:max_deg+1);
    P_k = degree_counts / numNodes;
    degree_edges = degree_edges(P_k ~=0);
    P_k = P_k(P_k ~= 0);
    
    avg_degree = mean(node_degrees);
    
    % 2)
    clustering_coefficients = clusteringcoeff(G);
    
    [cc_counts,cc_edges] = histcounts(clustering_coefficients, 'BinMethod', 'auto');
    P_cc = cc_counts/numNodes;
    cc_edges = cc_edges(P_cc ~=0);
    P_cc = P_cc(P_cc ~= 0);
    
    avg_cc = mean(clustering_coefficients);
    
    % 3)
    shortest_paths = distances(G);
    shortest_paths(shortest_paths == Inf) = NaN;
    shortest_paths = shortest_paths(~isnan(shortest_paths));
    
    [max_sp,~] = max(shortest_paths);
    [sp_counts,sp_edges] = histcounts(shortest_paths, 0:max_sp+1);
    P_sp = sp_counts/sum(sp_counts);
    
    diameter = max(shortest_paths(:), [], 'omitnan');
    avg_path_length = mean(shortest_paths(:), 'omitnan');
    
    % Display
    disp('Degree Distribution P(k):');
    disp(table(degree_edges', P_k', 'VariableNames', {'Degree', 'Probability'}));
    
    disp('Clustering Coefficient Distribution P(cc):');
    disp(table((cc_edges)', P_cc', 'VariableNames', {'ClusteringCoefficient', 'Probability'}));
    
    disp('Shortest Path Length Distribution P(sp):');
    disp(table(sp_edges(1:end-1)', P_sp', 'VariableNames', {'PathLength', 'Probability'}));
    
    disp('Graph Metrics:');
    metrics_table = table(avg_degree, avg_cc, diameter, avg_path_length, ...
        'VariableNames', {'AverageDegree', 'AverageClusteringCoefficient', 'Diameter', 'AveragePathLength'});
    disp(metrics_table);

    figure;
    % https://www.mathworks.com/matlabcentral/answers/254690-how-can-i-display-a-matlab-table-in-a-figure
    % Get the table in string form.
    TString = evalc('disp(metrics_table)');
    % Use TeX Markup for bold formatting and underscores.
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    % Get a fixed-width font.
    FixedWidth = get(0,'FixedWidthFontName');
    % Output the table using the annotation command.
    annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
    
    % Plot the distributions
    figure;
    bar(degree_edges, P_k);
    title('Degree Distribution P(k)');
    xlabel('Degree k');
    ylabel('Probability P(k)');
    
    figure;
    bar(cc_edges, P_cc);
    title('Clustering Coefficient Distribution P(cc)');
    xlabel('Clustering Coefficient');
    ylabel('Probability P(cc)');
    
    figure;
    bar(sp_edges(1:end-1), P_sp);
    title('Shortest Path Length Distribution P(sp)');
    xlabel('Path Length');
    ylabel('Probability P(sp)');
end

%% Random graphs

%% 1) Erdos-Renyi

n = 200;
m = 600;
seed = 42;

G = create_ER_Graph(n, m, seed);

figure;
p = plot(G,'NodeColor','k');
p.NodeLabel = {};
title('Erdos-Renyi Graph with $N = 200$ nodes, $m=600$');

graph_metrics(G,numnodes(G))


%% 2) Erdos-Renyi-Gilbert
n = 200;
p = 0.03;
seed = 42;
format = 1;

[G, n, m] = create_ERG_Graph(n, p, seed, format);

[row, col] = find(G);
edges = [row, col];

graphG = graph(edges(:,1), edges(:,2));

% Plot the graph
figure;
p = plot(graphG,'NodeColor','k');
p.NodeLabel={};
title('Erdos-Renyi-Gilbert Graph with $N = 200$ nodes and $p = 0.03$');

graph_metrics(graphG,numnodes(graphG))

%% 3)
N = 200;
K = 6;
beta = 0.1;
h1 = WattsStrogatz(N,K,beta);

figure;
p = plot(h1,'NodeColor','k');
title('Watts-Strogatz Graph with $N = 200$ nodes, $K = 6$, and $\beta = 0.1$', ...
    'Interpreter','latex')
p.NodeLabel = {};

graph_metrics(h1,numnodes(h1))

