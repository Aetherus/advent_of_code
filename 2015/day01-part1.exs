#!/usr/bin/env elixir

File.read!("./day01-input.txt")
|> String.trim()
|> String.to_charlist()
|> Enum.map(fn
      ?( -> 1
      ?) -> -1
    end)
|> Enum.sum()
|> IO.inspect()
