defmodule Assertion.Stats do
  @name __MODULE__

  def start_link do
    Agent.start_link(fn -> %{total: 0, passes: 0, failures: 0} end, name: @name)
  end

  def test_pass do
    Agent.update(@name, fn dict ->
      Dict.update(dict, :passes, &(&1), fn(val) -> val+1 end)
    end)

    update_test_case_count
  end

  def test_fail do
    Agent.update(@name, fn dict ->
      Dict.update(dict, :failures, &(&1), fn(val) -> val+1 end)
    end)

    update_test_case_count
  end

  def update_test_case_count do
    Agent.update(@name, fn dict ->
      Dict.update(dict, :total, &(&1), fn(val) -> val+1 end)
    end)
  end

  def count_for(term) do
    Agent.get(@name, fn dict -> Dict.get(dict,term) end)
  end

  def terms do
    Agent.get(@name, fn dict -> Dict.keys(dict) end)
  end

  # returns a new map with values reset
  def reset do
    Agent.update(@name, fn dict ->
      %{dict| passes: 0, failures: 0, total: 0}
    end)
  end

  def report do
    IO.puts """
    ===============================================
    TEST REPORT
    ===============================================
    Pass: #{Assertion.Stats.count_for(:passes)}
    Failures: #{Assertion.Stats.count_for(:failures)}
    Total test cases: #{Assertion.Stats.count_for(:total)}
    """

    Assertion.Stats.reset
  end
end

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
        Assertion.Test.run(@tests, __MODULE__)
      end
    end
  end

  defmacro test(description, do: test_block) do
    test_func = String.to_atom(description)
    quote do
      @tests {unquote(test_func), unquote(description)}
      def unquote(test_func)(), do: unquote(test_block)
    end
  end

  defmacro assert(assertion) do
    translate_assertion(assertion)
  end

  defmacro refute(assertion) do
    translate_assertion({:!, [], [assertion]})
  end

  @operator [:==, :<, :>, :<=, :>=, :===, :=~, :!==, :!=, :in]

  defp translate_assertion({operator, _, [left, right]} = expr) when operator in @operator  do
    expr = Macro.escape(expr)
    quote do
      left  = unquote(left)
      right = unquote(right)
      assert unquote(operator)(left, right),
             left: left,
             right: right,
             expr: unquote(expr),
             message: unquote("Assertion with #{operator} failed")
    end
  end

  defp translate_assertion({:!, [], [{operator, _, [left, right]} = expr]}) when operator in @operator do
    expr = Macro.escape(expr)
    quote do
      left  = unquote(left)
      right = unquote(right)
      assert not(unquote(operator)(left, right)),
             left: left,
             right: right,
             expr: unquote(expr),
             message: unquote("Refute with #{operator} failed")
    end
  end

  def assert(value, message) when is_binary(message) do
    assert(value, message: message)
  end

  def assert(value, opts) when is_list(opts) do
    Assertion.Stats.start_link

    if value do
      Assertion.Stats.test_pass
      IO.write "."
    else
      Assertion.Stats.test_fail
      IO.puts ""
      reason = opts
      IO.puts """
      ===============================================
      FAILURE: #{reason[:message]}
      ===============================================
      code: #{Macro.to_string(reason[:expr])}
      lhs: #{reason[:left]}
      rhs: #{reason[:right]}
      """
    end
  end
end

defmodule Assertion.Test do
  def run(tests, module) do
    tests
    |> Enum.reverse
    |> Enum.each fn {test_func, description} ->
      apply(module, test_func, [])
    end

    Assertion.Stats.report
  end
end
