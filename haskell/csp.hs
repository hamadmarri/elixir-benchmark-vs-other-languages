module Main where

import System.IO (hFlush, stdout)
import Text.Printf (printf)

--------------------------------------------------------------------------------
-- Configuration Constants
--------------------------------------------------------------------------------

entropy :: Int
entropy = 10

maxDigit :: Int
maxDigit = entropy

-- Generates the list: [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
rng :: [Int]
rng = [entropy, entropy - 1 .. 1]

--------------------------------------------------------------------------------
-- Core Solver Logic (Csp.NormalList.Solver)
--------------------------------------------------------------------------------

-- | Equivalent to Csp.NormalList.Solver.init/0
initQueue :: [[Int]]
initQueue = [[x] | x <- rng]

-- | Equivalent to Csp.NormalList.Solver.generate/3
generate :: [[Int]] -> [Int] -> Int -> ([[Int]], Int)
generate q parentItems stat
  | length parentItems >= maxDigit = (q, stat)
  | otherwise =
      -- For each 'c' in rng, prepend it to parentItems: [c | parent_items]
      let children = [[c] ++ parentItems | c <- rng]
       in (children ++ q, stat + entropy)

-- | Equivalent to Csp.NormalList.Solver.solve/3
-- Catch empty list explicitly to handle the safety fallback structure gracefully
solve :: [[Int]] -> [Int] -> Int -> IO ()
solve [] _ stat = do
  printf "q IS EMPTY!, QUITTING!, count: %d\n" stat
  hFlush stdout

solve (item : t) solution stat
  | isSolution item solution = do
      printf "FOUND A SOLUTION %s, count: %d\n" (show item) stat
      hFlush stdout
  | otherwise = do
      let (q, newStat) = generate t item stat
      if null q
        then do
          printf "q IS EMPTY!, QUITTING!, count: %d\n" newStat
          hFlush stdout
        else solve q solution newStat

-- | Private helper equivalent to is_solution?/2
isSolution :: [Int] -> [Int] -> Bool
isSolution item solution = item == solution

--------------------------------------------------------------------------------
-- Execution Pipeline (Csp.NormalList.start)
--------------------------------------------------------------------------------

main :: IO ()
main = do
  -- The target pattern matching your Elixir call:
  -- Csp.NormalList.start([7, 7, 7, 7, 7, 7, 7, 5, 10])
  let solution = [7, 7, 7, 7, 7, 7, 7, 5, 10]

  -- q = Solver.init()
  let q = initQueue

  -- IO.puts("QUEUE: #{inspect(q)}")
  printf "QUEUE: %s\n" (show q)
  hFlush stdout

  -- Solver.solve(q, solution, length(q))
  solve q solution (length q)
