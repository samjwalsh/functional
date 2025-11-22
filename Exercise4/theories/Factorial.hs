module Factorial where

-- if-based factorial 
iffac n = if n==0 then 1 else n * iffac (n-1)

-- guard-based factorial
gfac n
  | n == 0  =  1
  | True    =  n * gfac (n-1)

-- using otherwise instead of True
otherwise = True

-- otherwise-based guard-based factorial
ofac n
  | n == 0     =  1
  | otherwise  =  n * ofac (n-1)

-- pattern-based factorial
pfac 0  =  1
pfac n  =  n * pfac (n-1)
