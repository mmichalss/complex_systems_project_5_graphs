% project 5: graphs
% start: 17.12.2024

% https://www.mathworks.com/matlabcentral/answers/15318-gml-files-in-matlab
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
plot(G);

nNode = length(nodes);
W = sparse(s,t,true,nNode,nNode);
W = W | W';

net = networkvisualizer(W);

% Add labels to nodes
net.setNodeLabels(all_names);
net.setNodeSizes('auto');

% Prepare the figure and plot
figure(2);
set(gcf, 'Position', [0 0 1200 640]);
set(gcf, 'Color', [1 1 1]);
plot(net);
movegui('center');

