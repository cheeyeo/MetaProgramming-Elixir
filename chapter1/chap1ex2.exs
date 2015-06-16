#  Define a macro that returns a raw AST that you’ve written by hand, instead of using quote for code generation.

defmodule MyAst do
  defmacro macro_to_ast(expr) do
    # inside macro expr is already an ast
    IO.inspect expr
    Macro.escape(expr)
  end
end
