defmodule MyUnless do
  defmacro unless(expr, do: block) do
    quote do
      case unquote(expr) do
        result when result in [false,nil] -> unquote(block)
        _ -> "ITS TRUE SO NOT CALLED!"
      end
    end
  end
end


require MyUnless

MyUnless.unless 1==2, do: "SHOULD BE PRINTED!"

