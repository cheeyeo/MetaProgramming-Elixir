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
