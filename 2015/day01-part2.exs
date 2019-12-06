#!/usr/bin/env elixir

File.read!("./day01-input.txt")
|> String.trim()
|> String.to_charlist()
|> Stream.map(fn
      ?( -> 1
      ?) -> -1
    end)
|> Stream.with_index(1)
|> Enum.reduce(0, fn({d, i}, s) ->
     s = s + d
     if s == -1, do: IO.inspect(i)
     s
   end)
