defmodule ControlFlow do
  defmacro unless(expression, do: block) do
    quote do
      if !unquote(expression), do: unquote(block)
    end
  end
end

# require ControlFlow
# ControlFlow.unless 1==2, do: IO.puts "This should be printed"
