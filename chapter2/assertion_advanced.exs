# TODO:
# Implement assert for every operator in elixir
# Add boolean assertions such as assert true
# Implement a refute macro for refutations
# Run test cases in parallel within Assertion.Test.run/2 via spawned processes
# Spawned processes need to send message back to parent??


# Add reports for module such as pass/fail counts, execution time and coloring

defmodule Assertion do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run, do: Assertion.Test.run(@tests, __MODULE__)
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  defmacro assert({operator, _, [lhs, rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

defmodule Assertion.Stats do
  use GenEvent

  def init(_opts) do
    {:ok, %{total: 0, passes: 0, failures: 0, skipped: 0}}
  end

  def handle_call(:stop, map) do
    {:remove_handler, map}
  end

  def handle_event({:test_finished, :pass}, %{total: total, passes: passes} = map) do
    {:ok, %{map | total: total + 1, passes: passes + 1}}
  end

  def handle_event({:test_finished, :fail}, %{total: total, failures: failures} = map) do
    {:ok, %{map | total: total + 1, failures: failures+1}}
  end

  def handle_event(_, map) do
    {:ok, map}
  end
end


defmodule Assertion.Test do
  def run(tests, module) do
    {:ok, pid} = GenEvent.start_link()
    GenEvent.add_handler(pid, Assertion.Stats, [])

    Enum.each tests, fn {test_func, description} ->

      # spawn fn ->
        case apply(module, test_func, []) do
          :ok ->
            GenEvent.notify(pid, {:test_finished, :pass})

            IO.puts "."
          {:fail, reason} ->
            GenEvent.notify(pid, {:test_finished, :fail})

            IO.puts """

            ===============================================
            FAILURE: #{description}
            ===============================================
            #{reason}
            """
        end
      # end # end spawn
    end # end each

    GenEvent.call(pid, Assertion.Stats, :stop)
  end

  def assert(:==, lhs, rhs) when lhs == rhs do
    :ok
  end
  def assert(:==, lhs, rhs) do
    {:fail, """
      Expected:       #{lhs}
      to be equal to: #{rhs}
      """
    }
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    :ok
  end
  def assert(:>, lhs, rhs) do
    {:fail, """
      Expected:           #{lhs}
      to be greater than: #{rhs}
      """
    }
  end
end
