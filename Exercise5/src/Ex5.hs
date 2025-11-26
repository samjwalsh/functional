module Ex5 where

-- required for Q1
data F6ormula -- the expression datatype
  = LitNum Float -- floating-point value
  | Ident String -- variable/identifier name
  | Div F6ormula F6ormula -- divide first by second
  | Diff F6ormula F6ormula -- subtracts second from first
  | Magnitude F6ormula -- absolute value
  -- the following are boolean expressions (using numbers)
  -- the number 0.0 represents False, all others represent True.
  | Not F6ormula -- logical not
  | IsGreater F6ormula F6ormula -- True if first is greater than second
  | NotZero F6ormula -- True if numeric value is non-zero
  deriving (Eq, Ord, Show)

type Dict = [(String, Float)]

insert :: String -> Float -> Dict -> Dict
insert s f d = (s, f) : d

find :: (MonadFail m) => String -> Dict -> m Float
find s [] = fail (s ++ " not found")
find s ((t, f) : d)
  | s == t = return f
  | otherwise = find s d

-- required for Q2
x `incfst` _ = x + 1

_ `incsnd` y = 1 + y

type Thing = ([Int], [Float])

-- required for all Qs:

-- DON'T RENAME THE SPECIFIED TYPES OR FUNCTIONS
-- DON'T MODIFY ANYTHING ABOVE THIS LINE

-- Q1 (7 marks)
-- implement the following function (which should always return a value):
mdeval :: (MonadFail m) => Dict -> F6ormula -> m Float
mdeval _ (LitNum f) = return f
mdeval d (Ident s) = find s d
mdeval d (Div f1 f2) = do
  v1 <- mdeval d f1
  v2 <- mdeval d f2
  if v2 == 0 then fail "Division by zero" else return (v1 / v2)
mdeval d (Diff f1 f2) = do
  v1 <- mdeval d f1
  v2 <- mdeval d f2
  return (v1 - v2)
mdeval d (Magnitude f) = do
  v <- mdeval d f
  return (abs v)
mdeval d (Not f) = do
  v <- mdeval d f
  return (if v == 0 then 1 else 0)
mdeval d (IsGreater f1 f2) = do
  v1 <- mdeval d f1
  v2 <- mdeval d f2
  return (if v1 > v2 then 1 else 0)
mdeval d (NotZero f) = do
  v <- mdeval d f
  return (if v /= 0 then 1 else 0)

-- Q2 (4 marks)
-- Consider the following four recursive pattern definitions:
len :: Int -> [Int] -> Int
len z [] = z
len z (x : xs) = x `incsnd` (len z xs)

sumup :: Int -> [Int] -> Int
sumup sbase [] = sbase
sumup sbase (n : ns) = n + (sumup sbase ns)

prod :: Int -> [Int] -> Int
prod mbase [] = mbase
prod mbase (n : ns) = n * (prod mbase ns)

cat :: [Thing] -> [[Thing]] -> [Thing]
cat pfx [] = pfx
cat pfx (xs : xss) = xs ++ (cat pfx xss)

-- They all have the same abstract pattern,
-- as captured by the following Higher Order Function (HOF):
foldR z _ [] = z
foldR z op (x : xs) = x `op` foldR z op xs

-- We can gather the `z` and `opr` arguments into a tuple: (op,z)
-- which allows us to construct a call to foldR as:
dofold (op, z) = foldR z op

-- Your task is to complete the tuples below,
-- so that `dofold` can be used to implement the fns. above.

-- dofold lenTuple = len
lenTuple :: (Int -> Int -> Int, Int)
lenTuple = (incsnd, 0)

-- dofold sumupTuple = sumup
sumupTuple :: (Int -> Int -> Int, Int)
sumupTuple = ((+), 0)

-- dofold prodTuple = prod
prodTuple :: (Int -> Int -> Int, Int)
prodTuple = ((*), 1)

-- dofold catTuple = cat
catTuple :: ([Thing] -> [Thing] -> [Thing], [Thing])
catTuple = ((++), [])

-- Q3 (14 marks)
-- Q3 requires you to modify and submit Main.hs
-- That program has a number of tasks to perform that involve:
--   Reading a file; Processing contents; Writing results to a file.
--
-- Task 1:
--   Input: numbers.txt, [Int] in Haskell Syntax
--   Output: classified.txt, see below for format
--
-- You are given six numbers we call 'factors': 23 5 85 17 115 391
-- Read a list of Ints from the input file.
-- Take the list and split its contents into seven lists as follows:
-- The first six lists contain numbers that are multiples of the factors
-- The seventh contains numbers that are not multiples of any factor.
-- The seven lists are then written to the output file
-- in the following format:
--   (factor,[list-of-multiples]) - one of these per line.
-- Note: factor ordering matters:
--   1. An input number that is a multiple of more than one factor is
--      associated with the one that appears first in the above list.
--   2. The results are written in the order determined by the above list.
--
-- Task 2:
--   Input: numlists.txt, [[Int]] in Haskell Syntax
--   Output: ft_transpose.txt, see below for format
--
-- The input file contains a list of lists of Ints [[Int]]
-- The task is to compute the transpose of those lists.
-- We add 'fault-tolerance' by using the Maybe type,
-- where we use Nothing to pad out lists that are too short.
-- The output will have the type [[Maybe Int]]
--
-- Example of file formats can be found in the 'samples' folder.
--

-- add extra material below here
-- e.g.,  helper functions, test values, etc. ...
