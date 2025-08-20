defmodule RpnTest do
  use ExUnit.Case

  describe "" do
    setup _context do
      assert {:ok, pid} = Rpn.start_link(nil)
      assert Process.alive?(pid)

      {:ok, server: pid}
    end

    test "store number", context do
      %{server: pid} = context

      assert :ok = Rpn.push(pid, 5)

      assert [5] = Rpn.content(pid)
    end

    test "store two numbers", context do
      %{server: pid} = context

      assert :ok = Rpn.push(pid, 5)
      assert :ok = Rpn.push(pid, 3)

      assert [3, 5] = Rpn.content(pid)
    end

    @beep ~c"\b"
    test "add two numbers", context do
      %{server: pid} = context

      assert :ok = Rpn.push(pid, 5)
      assert :ok = Rpn.push(pid, 3)
      assert :ok = Rpn.push(pid, "+")

      assert [8] = Rpn.content(pid)

      assert {:error, _} = Rpn.push(pid, "+")

      # BEEP!
      assert @beep = Rpn.content(pid)
    end

    test "add more than two numbers", context do
      %{server: pid} = context

      assert :ok = Rpn.push(pid, 5)
      assert :ok = Rpn.push(pid, 2)
      assert :ok = Rpn.push(pid, 3)
      assert :ok = Rpn.push(pid, 1)
      assert :ok = Rpn.push(pid, "+")

      assert [4, 2, 5] = Rpn.content(pid)

      assert :ok = Rpn.push(pid, "+")
      assert [6, 5] = Rpn.content(pid)
    end
  end
end
