function G = create_ER_Graph(n, m, seed)
    rng(seed);
    possible_edges = nchoosek(1:n, 2);

    selected_edges_idx = randperm(size(possible_edges, 1), m);
    selected_edges = possible_edges(selected_edges_idx, :);

    G = graph(selected_edges(:, 1), selected_edges(:, 2));
end