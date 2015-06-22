defmodule Assertion do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute __MODULE__, :tests, accumulate: true

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

end
