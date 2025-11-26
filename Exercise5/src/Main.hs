module Main where

import Data.List (intercalate)
import Ex5

main :: IO ()
main = do
  putStrLn "Running Exercise5."
  putStrLn ""

  -- Task 1: Classify numbers by factors
  task1

  -- Task 2: Fault-tolerant transpose
  task2

-- Task 1: Read numbers, classify by factors, write results
task1 :: IO ()
task1 = do
  contents <- readFile "numbers.txt"
  let numbers = read contents :: [Int]
      factors = [23, 5, 85, 17, 115, 391]
      classified = classifyByFactors factors numbers
      output = unlines $ map formatClassified classified
  writeFile "classified.txt" output
  putStrLn "Task 1 completed: classified.txt written."

-- Classify numbers into groups based on factors (first matching factor wins)
-- Returns list of (factor, [multiples]) plus (0, [non-multiples])
classifyByFactors :: [Int] -> [Int] -> [(Int, [Int])]
classifyByFactors factors nums =
  let (classified, remaining) = foldl classifyOne ([], nums) factors
   in classified ++ [(0, remaining)]
  where
    classifyOne :: ([(Int, [Int])], [Int]) -> Int -> ([(Int, [Int])], [Int])
    classifyOne (acc, remaining) f =
      let (multiples, notMultiples) = partition (`isMultipleOf` f) remaining
       in (acc ++ [(f, multiples)], notMultiples)

    isMultipleOf n f = n `mod` f == 0

    partition :: (a -> Bool) -> [a] -> ([a], [a])
    partition p xs = (filter p xs, filter (not . p) xs)

-- Format a (factor, multiples) pair for output
formatClassified :: (Int, [Int]) -> String
formatClassified (f, ms) = "(" ++ show f ++ "," ++ show ms ++ ")"

-- Task 2: Read list of lists, compute fault-tolerant transpose
task2 :: IO ()
task2 = do
  contents <- readFile "numlists.txt"
  let numLists = read contents :: [[Int]]
      transposed = ftTranspose numLists
      output = formatMaybeMatrix transposed
  writeFile "ft_transpose.txt" output
  putStrLn "Task 2 completed: ft_transpose.txt written."

-- Fault-tolerant transpose: pad shorter lists with Nothing
ftTranspose :: [[Int]] -> [[Maybe Int]]
ftTranspose [] = []
ftTranspose xss
  | all null xss = []
  | otherwise = map safeHead xss : ftTranspose (map safeTail xss)
  where
    safeHead [] = Nothing
    safeHead (x : _) = Just x

    safeTail [] = []
    safeTail (_ : xs) = xs

-- Format the Maybe matrix for output
formatMaybeMatrix :: [[Maybe Int]] -> String
formatMaybeMatrix rows = "[" ++ intercalate "\n," (map formatRow rows) ++ "]\n"
  where
    formatRow :: [Maybe Int] -> String
    formatRow ms = "[" ++ intercalate "," (map formatMaybe ms) ++ "]"

    formatMaybe :: Maybe Int -> String
    formatMaybe Nothing = "Nothing"
    formatMaybe (Just x) = "Just " ++ show x
