graph = :digraph.new([:acyclic, :private])

edges = File.stream!("./day06-input.txt")
        |> Enum.map(fn line -> line |> String.trim() |> String.split(")") end)

vertices = edges
          |> List.flatten()
          |> MapSet.new()

Enum.each(vertices, fn vertex -> :digraph.add_vertex(graph, vertex) end)

Enum.each(edges, fn [v1, v2] -> :digraph.add_edge(graph, v2, v1) end)

vertices
|> Stream.map(fn vertex -> :digraph.get_path(graph, vertex, "COM") end)
|> Stream.filter(& &1)
|> Stream.map(fn path -> length(path) - 1 end)
|> Enum.sum()
|> IO.inspect()
