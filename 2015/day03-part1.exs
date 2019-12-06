File.read!("./day03-input.txt")
|> String.trim()
|> String.to_charlist()
|> Stream.map(fn
    ?^ -> {0, 1}
    ?v -> {0, -1}
    ?< -> {-1, 0}
    ?> -> {1, 0}
end)
|> Enum.reduce([{0, 0}], fn({dx, dy}, [{x, y} | _] = acc) -> [{x + dx, y + dy} | acc] end)
|> MapSet.new()
|> MapSet.size()
|> IO.inspect()
