defmodule Csp.NormalList.Solver do
  @compile {:inline, is_solution?: 2, generate: 4, solve: 3}

  @entropy 10
  @max_digit @entropy
  @rng Enum.to_list(@entropy..1)

  def init() do
    # Instead of just [item], store a tuple: {[item], length}
    # This mirrors Haskell's QueueItem data structure.
    Enum.map(@rng, &{[&1], 1})
  end

  # Pass the parent_len explicitly as an argument to avoid calling length/1
  def generate(q, parent_items, parent_len, stat) do
    if parent_len >= @max_digit do
      {q, stat}
    else
      # Create children as tuples containing the new list and pre-computed length
      # Using a flat list comprehension reduces allocation overhead
      children = for c <- @rng, do: {[c | parent_items], parent_len + 1}

      # children ++ q is still used, but now elements inside are optimized tuples
      {children ++ q, stat + @entropy}
    end
  end

  # Pattern match on the tuple structure: {item, item_len}
  def solve([{item, item_len} | t], solution, stat) do
    if is_solution?(item, solution) do
      IO.puts("FOUND A SOLUTION #{inspect(item, charlists: :as_list)}, count: #{stat}")
      :ok
    else
      {q, stat} = generate(t, item, item_len, stat)

      case q do
        [] ->
          IO.puts("q IS EMPTY!, QUITTING!, count: #{stat}")
          :exit

        _ ->
          solve(q, solution, stat)
      end
    end
  end

  defp is_solution?(item, solution), do: item == solution
end
