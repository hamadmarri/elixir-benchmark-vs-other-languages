{-# LANGUAGE BangPatterns #-}
{-# LANGUAGE TypeApplications #-}

-- {-# LANGUAGE CPP #-}

module Main where

import System.IO (hFlush, stdout)
import Text.Printf (printf)

data QueueItem = QItem
  { itemVals :: ![Int],
    itemLen :: {-# UNPACK #-} !Int
  }

initQueue :: [Int] -> [QueueItem]
initQueue rng = [QItem [x] 1 | x <- rng]

newChildren :: [QueueItem] -> [Int] -> Int -> [Int] -> [QueueItem]
newChildren !q _ _ [] = q
newChildren !q parentItems parentLen (c : rngs) = newChildren newQ parentItems parentLen rngs
  where
    newQ = (QItem (c : parentItems) parentLen) : q

generate :: [QueueItem] -> [Int] -> Int -> Int -> [Int] -> Int -> ([QueueItem], Int)
generate q parentItems parentLen entropy rng !stat
  | parentLen >= entropy = (q, stat)
  | otherwise = ((newChildren q parentItems (parentLen + 1) rng), stat + entropy)

solve :: [QueueItem] -> [Int] -> Int -> [Int] -> Int -> IO ()
solve [] _ _ _ !stat = do
  printf "q IS EMPTY!, QUITTING!, count: %d\n" stat
  hFlush stdout
solve (QItem item iLen : t) solution !entropy !rng !stat
  | iLen == 9 && item == solution = do
      printf "FOUND A SOLUTION %s, count: %d\n" (show item) stat
      hFlush stdout
  | otherwise = solve q solution entropy rng newStat
  where
    (q, !newStat) = generate t item iLen entropy rng stat

main :: IO ()
main = do
  let solution = [7, 7, 7, 7, 7, 7, 7, 5, 10]
      --   let solution = [8, 8, 8, 8, 8, 8, 8, 8, 10]
      entropy = 10 :: Int
      rng = [1 .. entropy]
      q = initQueue (reverse rng)

  printf "QUEUE: %s\n" (show (map itemVals q))
  hFlush stdout

  solve q solution entropy rng (length q)
