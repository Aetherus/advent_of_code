#!/usr/bin/env elixir

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

##########
# Part 1 #
##########

System.argv()
|> hd()
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.map(&Fuel.for_mass/1)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

##########
# Part 2 #
##########

System.argv()
|> hd()
|> File.stream!()
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.map(&Fuel.for_mass_recursive/1)
|> Enum.sum()
|> IO.inspect(label: "Part 2")
