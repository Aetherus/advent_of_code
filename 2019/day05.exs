#!/usr/bin/env elixir

defmodule IntcodeComputer do

  @spec run(list(integer)) :: %{non_neg_integer => integer}
  def run(program) do
    program = program
              |> Stream.with_index()
              |> Stream.map(fn {n, i} -> {i, n} end)
              |> Enum.into(%{})
    run(program, 0)
  end

  @instructions %{
    1 => {:add, 2, true},
    2 => {:multiply, 2, true},
    3 => {:read, 0, true},
    4 => {:print, 1, false},
    5 => {:jump_if_true, 2, false},
    6 => {:jump_if_false, 2, false},
    7 => {:less_than, 2, true},
    8 => {:equal_to, 2, true},
    99 => {:halt, 0, false}
  }

  defp run(program, pointer) do
    op_and_modes = program[pointer]
    op = rem(op_and_modes, 100)

    {func, arity, has_return} = @instructions[op]
    modes = op_and_modes
            |> div(100)
            |> Integer.digits()
            |> rjust(arity, 0)
            |> Enum.reverse()

    args = 1..arity
           |> Enum.zip(modes)
           |> Enum.map(fn {offset, mode} -> get_arg(program, pointer + offset, mode) end)

    return_address = if has_return, do: program[pointer + arity + 1], else: nil

    {new_program, new_pointer} = apply(__MODULE__, func, [program, pointer, return_address | args])
    if new_pointer != :halt do
      run(new_program, new_pointer)
    else
      new_program
    end
  end

  defp rjust(_, 0, _), do: []

  defp rjust(list, size, _padding) when length(list) == size, do: list

  defp rjust(list, size, padding), do: rjust([padding | list], size, padding)

  defp get_arg(program, position, 0), do: program[program[position]]

  defp get_arg(program, position, 1), do: program[position]

  def add(program, pointer, write_to, v1, v2) do
    {Map.put(program, write_to, v1 + v2), pointer + 4}
  end

  def multiply(program, pointer, write_to, v1, v2) do
    {Map.put(program, write_to, v1 * v2), pointer + 4}
  end

  def read(program, pointer, write_to) do
    value = IO.gets("A number: ")
            |> String.trim()
            |> String.to_integer()
    {Map.put(program, write_to, value), pointer + 2}
  end

  def print(program, pointer, _, value) do
    IO.puts(value)
    {program, pointer + 2}
  end

  def jump_if_true(program, pointer, _, 0, _jump_to), do: {program, pointer + 3}
  def jump_if_true(program, _pointer, _,  _, jump_to), do: {program, jump_to}

  def jump_if_false(program, _pointer, _, 0, jump_to), do: {program, jump_to}
  def jump_if_false(program, pointer, _, _v, _jump_to), do: {program, pointer + 3}

  def less_than(program, pointer, write_to, v1, v2) do
    {Map.put(program, write_to, (if v1 < v2, do: 1, else: 0)), pointer + 4}
  end

  def equal_to(program, pointer, write_to, v1, v2) do
    {Map.put(program, write_to, (if v1 == v2, do: 1, else: 0)), pointer + 4}
  end

  def halt(program, _pointer, _), do: {program, :halt}
end

System.argv()
|> hd()
|> File.read!()
|> String.trim()
|> String.split(",")
|> Enum.map(&String.to_integer/1)
|> IntcodeComputer.run()
