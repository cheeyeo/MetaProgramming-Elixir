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
      def run do
        IO.puts "Running the tests: #{inspect @tests}"
      end
    end
  end

  defmacro test(desc, block) do
    test_func = String.to_atom(desc)
    quote do
      @tests {unquote(test_func), unquote(block) }
      def unquote(test_func)(), do: unquote(block)
    end
  end

  defmacro assert({operator,_,[lhs,rhs]}) do
    quote bind_quoted: [operator: operator, lhs: lhs, rhs: rhs] do
      Assertion.Test.assert(operator, lhs, rhs)
    end
  end
end

defmodule Assertion.Test do
  def assert(:==, lhs, rhs) when lhs == rhs do
    IO.puts "."
  end

  def assert(:==, lhs, rhs) do
    IO.puts """
    Failure:

    Expected        #{lhs}
    to be equal to: #{rhs}
    """
  end

  def assert(:>, lhs, rhs) when lhs > rhs do
    IO.puts "."
  end

  def assert(:>, lhs, rhs) do
    IO.puts """
    Failure:

    Expected            #{lhs}
    to be greater than: #{rhs}
    """
  end
end
