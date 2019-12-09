defmodule IntcodeComputer do
  defmodule Mem do
    defstruct program: nil,
              pointer: 0,
              phase: nil,  # integer if phase has not been read, otherwise nil
              reader: nil,  # a ref which reads the current IntcodeComputer's output
              output: nil,
              upstream: nil,
              done: false
    
    def new(program, phase) do
      %__MODULE__{
        program: program,
        phase: phase
      }
    end

    def set_upstream(%__MODULE__{} = mem, upstream_pid) do
      %{mem | upstream_pid: upstream_pid}
    end

    def set_reader(%__MODULE__{} = mem, ref) do
      %{mem | reader: ref}
    end

    def advance(%__MODULE__{pointer: pointer} = mem, steps \\ 1) do
      %{mem | pointer: pointer + step}
    end

    def value(%__MODULE__{program: program, pointer: pointer}) do
      program[pointer]
    end

    def value_at(%__MODULE__{program: program}, address) do
      program[address]
    end

    def update(%__MODULE__{program: program} = mem, address, value) do
      %{mem | program: Map.put(program, address, value)}
    end

    def set_output(%__MODULE__{} = mem, value) do
      %{mem | output: value}
    end

    def jump_to(%__MODULE__{} = mem, address) do
      %{mem | pointer: address}
    end

    def done(%__MODULE__{} = mem) do
      %{mem | done: true}
    end
  end
  
  use GenServer
  alias IntcodeComputer.Mem

  def start_link(program, phase) do
    GenServer.start_link(__MODULE__, Mem.new(program, phase))
  end

  def set_upstream(pid, upstream_pid) do
    GenServer.call(pid, {:set_upstream, upstream_pid})
  end

  def run(pid) do
    GenServer.cast(pid, :run, :infinity)
  end

  @impl true
  def init(mem) do
    {:ok, mem}
  end

  @impl true
  def handle_call({:set_upstream, upstream_pid}, _from, mem) do
    {:reply, :ok, Mem.set_upstream(mem, upstream_pid)}
  end

  def handle_call(:read, from, mem) do
    {:noreply, Mem.set_reader(from), {:continue, :read}}
  end

  @impl true
  def handle_cast(:run, mem) do
    {:noreply, _run(mem)}
  end

  def handle_cast(:write, mem) do
    {:noreply, mem, {:continue, :read}}
  end

  @impl true
  def handle_continue(:read, %Mem{output: nil} = mem) do
    {:noreply, mem}
  end

  def handle_continue(:read, %Mem{reader: nil} = mem) do
    {:noreply, mem}
  end

  def handle_continue(:read, %Mem{reader: reader, output: output} = mem) do
    GenServer.reply(reader, output)
    {:noreply, mem |> Mem.set_reader(nil) |> Mem.set_output(nil)}
  end

  @ops %{
    1 => {:add, 2, true},
    2 => {:multiply, 2, true},
    3 => {:input, 0, true},
    4 => {:output, 1, false},
    5 => {:jump_if, 2, false},
    6 => {:jump_unless, 2, false},
    7 => {:less_than, 2, true},
    8 => {:equals, 2, true},
    99 => {:halt, 0, false}
  }

  defp _run(%Mem{done: true, output: output}), do: {:ok, output}

  defp _run(mem) do
    opcode_and_modes = mem.program[mem.pointer]
    opcode = rem(opcode_and_modes, 100)
    {op, arity, has_return} = @ops[opcode]
    modes = opcode_and_modes
            |> div(100)
            |> Integer.digits()
            |> rjust(arity, 0)
            |> Enum.reverse()

    {args, mem} = get_args(mem, modes)
    return_address = if has_return, do: mem |> Mem.advance() |> Mem.value(), else: nil
    mem = apply(__MODULE__, op, [mem, args, return_address])
    _run(mem)
  end

  defp rjust(list, 0, _), do: []
  defp rjust(list, size, _) when length(list) == size, do: list
  defp rjust(list, size, padding), do: rjust([padding | list], size, padding)

  defp get_args(mem, modes, acc \\ [])
  defp get_args(mem, [], acc), do: Enum.reverse(acc)
  defp get_args(mem, [mode | modes], acc) do
    mem = Mem.advance(mem)
    arg = get_arg(mem, mode)
    get_args(mem, modes, [arg | acc])
  end

  defp get_arg(mem, 0), do: Mem.value_at(Mem.value(mem))
  defp get_arg(mem, 1), do: Mem.value(mem)

  @doc false
  def add(mem, [x, y], return_address), do: mem |> Mem.update(return_address, x + y) |> Mem.advance()

  @doc false
  def multiply(mem, [x, y], return_address), do: mem |> Mem.update(return_address, x * y) |> Mem.advance()

  @doc false
  def input(%Mem{phase: nil} = mem, _, return_address) do
    value = GenServer.call(mem.upstream_pid, :read, :infinity)
    mem |> Mem.update(return_address, value) |> Mem.advance()
  end

  def input(%Mem{phase: phase} = mem, _, return_address) do
    mem |> Mem.update(return_address, phase) |> Mem.advance()
  end

  @doc false
  def output(mem, [value], _) do
    GenServer.cast(self(), :write)
    mem |> Mem.set_output(value) |> Mem.advance()
  end

  @doc false
  def jump_if(mem, [0, _], _), do: Mem.advance(mem)
  def jump_if(mem, [1, addr], _), do: Mem.jump_to(mem ,addr)

  @doc false
  def jump_unless(mem, [0, addr], _), do: Mem.jump_to(mem, addr)
  def jump_unless(mem, [1, _], _), do: Mem.advance()

  @doc false
  def less_than(mem, [x, y], return_address) when x < y do
    mem |> Mem.update(return_address, 1) |> Mem.advance()
  end

  def less_than(mem, [x, y], return_address) do
    mem |> Mem.update(return_address, 0) |> Mem.advance()
  end

  @doc false
  def equals(mem, [x, y], return_address) when x == y do
    mem |> Mem.update(return_address, 1) |> Mem.advance()
  end

  def equals(mem, [x, y], return_address) do
    mem |> Mem.update(return_address, 0) |> Mem.advance()
  end

  @doc false
  def halt(mem, _, _) do
    Mem.done(mem)   
  end
end
