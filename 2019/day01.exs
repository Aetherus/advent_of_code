#!/usr/bin/env elixir

defmodule AdventOfCode.Year2019.Day01 do
  @external_resource "day01-input.txt"
  @input File.read!(hd(@external_resource)) |> String.trim() |> String.split() |> Enum.map(&String.to_integer/1)

  defmodule Fuel do
    @spec for_mass(non_neg_integer) :: non_neg_integer
    def for_mass(mass) do
      fuel = div(mass, 3) - 2
      if fuel > 0, do: fuel, else: 0
    end

    @spec for_mass_recursive(non_neg_integer) :: non_neg_integer
    def for_mass_recursive(mass) do
      for_mass_recursive(mass, 0)
    end

    defp for_mass_recursive(mass, acc) do
      fuel = for_mass(mass)
      if fuel > 0 do
        for_mass_recursive(fuel, acc + fuel)
      else
        acc
      end
    end
  end

  alias AdventOfCode.Year2019.Day01.Fuel

  def part1 do
    @input
    |> Stream.map(&Fuel.for_mass/1)
    |> Enum.sum()
  end

  def part2 do
    @input
    |> Stream.map(&Fuel.for_mass_recursive/1)
    |> Enum.sum()
  end
end

alias AdventOfCode.Year2019.Day01

IO.inspect(Day01.part1(), label: "Part 1")

IO.inspect(Day01.part2(), label: "Part 2")
