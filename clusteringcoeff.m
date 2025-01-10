function clustering_coefficient = clusteringcoeff(G)

A = adjacency(G);
clustering_coefficient = zeros(numnodes(G), 1);

for i = 1:numnodes(G)
    neighbors_i = find(A(i, :));
    k = numel(neighbors_i);
    if k < 2
        clustering_coefficient(i) = 0;
    else
        subgraph_edges = 0;
        for j = 1:k
            for l = j+1:k
                if A(neighbors_i(j), neighbors_i(l))
                    subgraph_edges = subgraph_edges + 1;
                end
            end
        end
        clustering_coefficient(i) = (2 * subgraph_edges) / (k * (k - 1));
    end
end