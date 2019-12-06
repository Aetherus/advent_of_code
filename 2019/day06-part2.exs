graph = :digraph.new([:cyclic, :private])

edges = File.stream!("./day06-input.txt")
        |> Enum.map(fn line -> line |> String.trim() |> String.split(")") end)

vertices = edges
           |> List.flatten()
           |> MapSet.new()

Enum.each(vertices, fn v -> :digraph.add_vertex(graph, v) end)

Enum.each(edges, fn [v1, v2] ->
  :digraph.add_edge(graph, v1, v2)
  :digraph.add_edge(graph, v2, v1)
end)

path = :digraph.get_short_path(graph, "YOU", "SAN")

IO.inspect(length(path) - 3)
