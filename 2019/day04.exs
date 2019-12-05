#!/usr/bin/env elixir

359999..799999
|> Stream.map(&Integer.digits/1)
|> Stream.reject(fn digits -> digits |> Stream.chunk_every(2, 1, :discard) |> Enum.any?(fn [a, b] -> a > b end) end)
#|> Stream.reject(fn digits -> digits |> Stream.chunk_every(2, 1, :discard) |> Enum.all?(fn [a, b] -> a != b end) end)
|> Stream.map(fn digits -> [:@] ++ digits ++ [:@] end)
|> Stream.filter(fn digits -> digits |> Stream.chunk_every(4, 1, :discard) |> Enum.any?(&match?([a, b, b, c] when a != b and b != c, &1)) end)
|> Enum.count()
|> IO.inspect()
