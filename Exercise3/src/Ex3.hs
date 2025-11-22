module Ex3 where

-- required for all Qs:
data MathExp6r -- the expression datatype
  = LitNum Float -- floating-point value
  | Ident String -- variable/identifier name
  | Div MathExp6r MathExp6r -- divide first by second
  | Sum MathExp6r MathExp6r -- adds both together
  | AddInv MathExp6r -- numerical negation (-x)
  -- the following are boolean expressions (using numbers)
  -- the number 0.0 represents False, all others represent True.
  | Not MathExp6r -- logical not
  | GrtOrEq MathExp6r MathExp6r -- True if first is greater than or equal to second
  | EqToZero MathExp6r -- True if numeric value is zero
  deriving (Eq, Ord, Show)

type Dict = [(String, Float)]

insert :: String -> Float -> Dict -> Dict
insert s f d = (s, f) : d

find :: String -> Dict -> Maybe Float
find s [] = Nothing
find s ((t, f) : d)
  | s == t = Just f
  | otherwise = find s d

-- DON'T RENAME THE SPECIFIED TYPES OR FUNCTIONS
-- DON'T MODIFY ANYTHING ABOVE THIS LINE

-- Q1 (8 marks)
-- Implement the following function (which may have runtime errors)
-- This will only be graded using dictionaries and values that do
-- not result in runtime errors in a correct implementation.
eval :: Dict -> MathExp6r -> Float
eval d (LitNum f) = f
eval d (Ident s) = case find s d of
  Just val -> val
  Nothing -> error ("Undefined variable: " ++ s)
eval d (Div e1 e2) = eval d e1 / eval d e2
eval d (Sum e1 e2) = eval d e1 + eval d e2
eval d (AddInv e) = -(eval d e)
eval d (Not e) = if eval d e == 0.0 then 1.0 else 0.0
eval d (GrtOrEq e1 e2) = if eval d e1 >= eval d e2 then 1.0 else 0.0
eval d (EqToZero e) = if eval d e == 0.0 then 1.0 else 0.0

-- Q2 (9 marks)
-- Implement the following function (which always returns a value)
-- Grading of this will put emphasis on cases that would cause a
-- runtime error for Q1.
meval :: Dict -> MathExp6r -> Maybe Float
meval d (LitNum f) = Just f
meval d (Ident s) = find s d
meval d (Div e1 e2) = do
  v1 <- meval d e1
  v2 <- meval d e2
  if v2 == 0.0
    then Nothing
    else Just (v1 / v2)
meval d (Sum e1 e2) = do
  v1 <- meval d e1
  v2 <- meval d e2
  Just (v1 + v2)
meval d (AddInv e) = do
  v <- meval d e
  Just (-v)
meval d (Not e) = do
  v <- meval d e
  Just (if v == 0.0 then 1.0 else 0.0)
meval d (GrtOrEq e1 e2) = do
  v1 <- meval d e1
  v2 <- meval d e2
  Just (if v1 >= v2 then 1.0 else 0.0)
meval d (EqToZero e) = do
  v <- meval d e
  Just (if v == 0.0 then 1.0 else 0.0)

-- Q3 (8 marks)
-- Laws of Arithmetic for this question:
--    x + 0 = x
--    0 + x = x
-- The following function should implement simplifications
-- using ONLY the above two laws, wherever they apply.
simp :: MathExp6r -> MathExp6r
simp (Sum e1 e2) =
  let s1 = simp e1
      s2 = simp e2
   in case (s1, s2) of
        (LitNum 0.0, e) -> e
        (e, LitNum 0.0) -> e
        (se1, se2) -> Sum se1 se2
simp (Div e1 e2) = Div (simp e1) (simp e2)
simp (AddInv e) = AddInv (simp e)
simp (Not e) = Not (simp e)
simp (GrtOrEq e1 e2) = GrtOrEq (simp e1) (simp e2)
simp (EqToZero e) = EqToZero (simp e)
simp e = e -- Base cases for LitNum and Ident

-- add extra material below here
-- e.g.,  helper functions, test values, etc. ...
