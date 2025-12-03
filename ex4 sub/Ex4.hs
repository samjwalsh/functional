
module Ex4 where

--required for Q1
data MathExpr -- the expression datatype
  = Number Float -- floating-point value
  | VName String -- variable/identifier name
  | Divide MathExpr MathExpr -- divide first by second
  | Times MathExpr MathExpr -- multiplies both
  | Magnitude MathExpr -- absolute value
  -- the following are boolean expressions (using numbers)
  -- the number 0.0 represents False, all others represent True.
  | Not MathExpr -- logical not
  | GrtOrEq MathExpr MathExpr -- True if first is greater than or equal to second 
  | EqToZero MathExpr -- True if numeric value is zero
  deriving (Eq,Ord,Show)

type Dict = [(String,Float)]
insert :: String -> Float -> Dict -> Dict
insert s f d = (s,f):d
find :: MonadFail m => String -> Dict -> m Float
find s [] = fail (s++" not found")
find s ((t,f):d)
  | s==t       =  return f
  | otherwise  =  find s d

-- required for Q2
x `incfst` _  =  x + 1
_ `incsnd` y  =  1 + y
type Thing = ([Float],Int)

-- required for all Qs:

-- DON'T RENAME THE SPECIFIED TYPES OR FUNCTIONS
-- DON'T MODIFY ANYTHING ABOVE THIS LINE

-- Q1 (8 marks)
-- implement the following function (which should always return a value):
mdeval :: MonadFail m => Dict -> MathExpr -> m Float
mdeval _ (Number x)                 = return x
mdeval d (VName v)                  = find v d
mdeval d (Divide e1 e2)             = do b <- mdeval d e2
                                         if b == 0.0
                                          then fail "divide by zero"
                                          else do a <- mdeval d e1
                                                  return (a/b)
mdeval d (Times e1 e2)              = do b <- mdeval d e2
                                         a <- mdeval d e1
                                         return (a*b)
mdeval d (Magnitude expr)           = do a <- mdeval d expr
                                         return (abs a)
mdeval d (Not expr)                 = do a <- mdeval d expr
                                         return (if a == 0.0 then 1.0 else 0.0)
mdeval d (GrtOrEq e1 e2)            = do a <- mdeval d e1
                                         b <- mdeval d e2
                                         return (if a >= b then 1.0 else 0.0)
mdeval d (EqToZero expr)            = do a <- mdeval d expr
                                         return (if a == 0.0 then 1.0 else 0.0)

-- Q2 (6 marks)
-- Consider the following four recursive pattern definitions:
len :: Int -> [Int] -> Int
len z []     = z
len z (x:xs) = x `incsnd` (len z xs)
sumup :: Int -> [Int] -> Int
sumup sbase []     = sbase
sumup sbase (n:ns) = n + (sumup sbase ns)
prod :: Int -> [Int] -> Int
prod mbase []     = mbase
prod mbase (n:ns) = n * (prod mbase ns)
cat :: [Thing] -> [[Thing]] -> [Thing]
cat pfx []     = pfx
cat pfx (xs:xss) = xs ++ (cat pfx xss)

-- They all have the same abstract pattern,
-- as captured by the following Higher Order Function (HOF):
foldR :: t1 -> (t2 -> t1 -> t1) -> [t2] -> t1
foldR z _ [] = z
foldR z op (x:xs) = x `op` foldR z op xs

-- We can gather the `z` and `opr` arguments into a tuple: (z,op)
-- which allows us to construct a call to foldR as:
dofold (z,op) = foldR z op

-- Your task is to complete the tuples below,
-- so that `dofold` can be used to implement the fns. above.

-- dofold lenTuple = len
lenTuple :: (Int,Int -> Int -> Int)
lenTuple = (0, incsnd)

-- dofold sumupTuple = sumupS
sumupTuple :: (Int,Int -> Int -> Int)
sumupTuple = (0,(+))

-- dofold prodTuple = prod
prodTuple :: (Int,Int -> Int -> Int)
prodTuple = (1,(*))

-- dofold catTuple = cat
catTuple :: ([Thing],[Thing] -> [Thing] -> [Thing])
catTuple = ([],(++))

-- Q3 (11 marks)
sub = subtract -- shorter!
ops :: [Integer -> Integer]
ops = [(sub 24),(*34),(+33),(+34),(sub 34),(+31),(28-),(sub 25),(sub 30)]

-- (!) This question requires modifying Main.hs
-- See, and/or compile and run Main.hs for further details

-- add extra material below here
-- e.g.,  helper functions, test values, etc. ...

applyOps :: [Integer -> Integer] -> [Integer] -> [Integer]
applyOps operations = zipWith ($) (cycle operations)
