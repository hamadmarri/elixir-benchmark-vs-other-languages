{-# LANGUAGE BangPatterns #-}

module Main where

import qualified Data.Vector as V
import qualified Data.Vector.Unboxed.Mutable as UM
import System.IO (hFlush, stdout)
import Text.Printf (printf)

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

entropy :: Int
entropy = 10

maxDigit :: Int
maxDigit = entropy

rng :: V.Vector Int
rng = V.fromList [1 .. entropy]

--------------------------------------------------------------------------------
-- Core Solver Logic
--------------------------------------------------------------------------------

data QueueItem = QItem {
    itemVals :: !(V.Vector Int),
    itemLen  :: {-# UNPACK #-} !Int
}

initQueue :: [QueueItem]
initQueue = [QItem (V.singleton x) 1 | x <- V.toList rng]

generate :: [QueueItem] -> V.Vector Int -> Int -> Int -> ([QueueItem], Int)
generate q parentItems parentLen !stat
    | parentLen >= maxDigit = (q, stat)
    | otherwise =
        let children = [QItem (V.cons c parentItems) (parentLen + 1) | c <- V.toList rng]
        in (children ++ q, stat + entropy)

solve :: [QueueItem] -> V.Vector Int -> Int -> IO ()
solve [] _ !stat = do
    printf "Q IS EMPTY!, QUITTING!, count: %d\n" stat
    hFlush stdout
solve (QItem item iLen : t) solution !stat
    | item == solution = do
        printf "FOUND A SOLUTION %s, count: %d\n" (show (V.toList item)) stat
        hFlush stdout
    | otherwise = do
        let (!q', !newStat) = generate t item iLen stat
        solve q' solution newStat

--------------------------------------------------------------------------------
-- Execution
--------------------------------------------------------------------------------

main :: IO ()
main = do
    let solution = V.fromList [8, 8, 8, 8, 8, 8, 8, 8, 10] :: V.Vector Int
    let q = initQueue

    printf "QUEUE INITIALIZED\n"
    putStrLn $ show solution
    hFlush stdout

    solve q solution (length q)
