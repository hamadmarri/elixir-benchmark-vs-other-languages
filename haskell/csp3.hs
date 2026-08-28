{-# LANGUAGE BangPatterns #-}
module Main where

import Data.Bits
import Data.Word
import qualified Data.Vector.Unboxed.Mutable as UM

-- Configuration
entropy :: Word64
entropy = 10

maxDigit :: Int
maxDigit = 10

solutionLen :: Int
solutionLen = 9

-- Pack the target solution into a Word64 for instantaneous O(1) comparison
solutionSeq :: Word64
solutionSeq = foldr (\x acc -> x .|. (acc `shiftL` 4)) 0 [7, 7, 7, 7, 7, 7, 7, 5, 10]

-- Unpack a Word64 sequence back into a list of numbers for printing
unpack :: Int -> Word64 -> [Word64]
unpack 0 _ = []
unpack l v = (v .&. 0xF) : unpack (l - 1) (v `shiftR` 4)

-- The main solver loop.
-- Passes the explicit stack (vector), stack pointer (sp), and statistic counter (stat).
solve :: UM.IOVector Word64 -> Int -> Int -> IO ()
solve !stack !sp !stat = do
    if sp == 0 then do
        putStrLn $ "Q IS EMPTY!, QUITTING!, count: " ++ (show stat)
    else do
        -- Pop the top state off the explicit stack
        let !sp' = sp - 1
        state <- UM.unsafeRead stack sp'

        -- Decode state: Bits 0-39 hold the digits, Bits 40-43 hold the length
        let !len = fromIntegral (state `shiftR` 40) .&. 0xF
        let !item = state .&. 0xFFFFFFFFFF

        -- O(1) instantaneous comparison (Equivalent to exact slice check)
        if len == solutionLen && item == solutionSeq then do
            let vals = unpack len item
            putStr "FOUND A SOLUTION "
            mapM_ (\v -> putStr (show v ++ " ")) vals
            putStrLn $ ", count: " ++ (show stat)

        else if len >= maxDigit then do
            solve stack sp' stat

        else do
            -- Generate children and push to stack
            let pushChildren !idx !i = do
                    if i > entropy then return idx
                    else do
                        -- Prepend logic: shift existing values left, insert new digit
                        let !childItem = i .|. (item `shiftL` 4)
                        let !childLen = len + 1
                        let !childState = (fromIntegral childLen `shiftL` 40) .|. childItem

                        UM.unsafeWrite stack idx childState
                        pushChildren (idx + 1) (i + 1)

            sp'' <- pushChildren sp' 1
            solve stack sp'' (stat + fromIntegral entropy)

main :: IO ()
main = do
    -- Allocate an unboxed mutable vector (our explicit stack)
    -- Max depth * entropy = 10 * 10 = 100. A capacity of 256 is entirely safe.
    stack <- UM.unsafeNew 128 --256

    -- Initialize the queue
    let initPush !idx !i = do
            if i > entropy then return idx
            else do
                let !state = (1 `shiftL` 40) .|. i
                UM.unsafeWrite stack idx state
                initPush (idx + 1) (i + 1)

    sp <- initPush 0 1

    -- Run the solver (initial stat count matches stack size)
    solve stack sp (fromIntegral entropy)

