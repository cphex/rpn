defmodule Rpn do
  @moduledoc """
  Rpn is Reverse Polish Notation calculator
  """

  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, [])
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def push(pid, number) when is_number(number) do
    :ok = GenServer.cast(pid, {:push, number})
  end

  def push(pid, "+") do
    GenServer.call(pid, {:operator, :plus})
  end

  def content(pid) do
    GenServer.call(pid, :content)
  end

  # --------------------------------------------------------------------

  @impl GenServer
  def init(_arg) do
    {:ok, []}
  end

  @impl GenServer
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:push, term}, state) do
    new_state = [term | state]

    {:noreply, new_state}
  end

  @impl GenServer
  def handle_call({:operator, :plus}, _from, state) do
    case state do
      [a, b | new_state] ->
        result = a + b
        {:reply, :ok, [result | new_state]}

      stack when length(stack) < 2 ->
        result = {:error, :too_few_arguments}
        {:reply, result, state}
    end
  end

  def handle_call(:content, _from, state) do
    current_state = state

    {:reply, current_state, state}
  end
end
