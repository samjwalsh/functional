module Main where

import Data.List (intercalate)
import Ex5

main :: IO ()
main = do
  task1
  task2

task1 :: IO ()
task1 = do
  contents <- readFile "numbers.txt"
  let numbers = read contents :: [Int]
      factors = [23, 5, 85, 17, 115, 391]
      classified = classifyByFactors factors numbers
      output = unlines $ map formatClassified classified
  writeFile "classified.txt" output

classifyByFactors :: [Int] -> [Int] -> [(Int, [Int])]
classifyByFactors factors nums =
  let (classified, remaining) = foldl classifyOne ([], nums) factors
   in classified ++ [(1, remaining)]
  where
    classifyOne :: ([(Int, [Int])], [Int]) -> Int -> ([(Int, [Int])], [Int])
    classifyOne (acc, remaining) f =
      let (multiples, notMultiples) = partition (`isMultipleOf` f) remaining
       in (acc ++ [(f, multiples)], notMultiples)

    isMultipleOf n f = n `mod` f == 0

    partition :: (a -> Bool) -> [a] -> ([a], [a])
    partition p xs = (filter p xs, filter (not . p) xs)

formatClassified :: (Int, [Int]) -> String
formatClassified (f, ms) = "(" ++ show f ++ ",[" ++ intercalate "," (map show ms) ++ "])"

task2 :: IO ()
task2 = do
  contents <- readFile "numlists.txt"
  let numLists = read contents :: [[Int]]
      transposed = ftTranspose numLists
  writeFile "ft_transpose.txt" (show transposed)

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
