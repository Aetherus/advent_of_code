Code.require_file("./intcode_computer.exs")

defmodule Permutations do
  def permutations([]), do: [[]]

  def permutations(list), do: for elem <- list, rest <- permutations(list--[elem]), do: [elem|rest]
end

program = "./day07-input.txt"
          |> File.read!()
          |> String.trim()
          |> String.split(",")
          |> Stream.map(&String.to_integer/1)
          |> Stream.with_index()
          |> Stream.map(fn {n, i} -> {i, n} end)
          |> Enum.into(%{})

[0, 1, 2, 3, 4]
|> Permutations.permutations()
|> Enum.map(fn phases ->
  computers = phases
              |> Stream.map(&IntcodeComputer.start_link(program, &1))
              |> Enum.map(&elem(&1, 1))
  computers
  |> Stream.chunk_every(2, 1, :discard)
  |> Enum.each(&IntcodeComputer.set_upstream/2)

  computers
  |> Enum.each(&IntcodeComputer.run/1)

  # TODO get output
end)
