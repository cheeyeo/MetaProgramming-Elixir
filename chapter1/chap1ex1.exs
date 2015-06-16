# Define an unless macro without depending on Kernel.if, by using other con- structs in Elixir for control flow.


defmodule ControlFlow do
  defmacro noifunless(expression, do: block) do
    quote do
      case unquote(expression) do
        result when result in [false, nil] -> unquote(block)
        _ -> "ITS TRUE! SO NOT CALLED!"
      end
    end
  end
end
