module List where

[] ++ ys      =  ys               -- ++.1
(x:xs) ++ ys  =  x:(xs ++ ys)     -- ++.2

reverse []        =  []               -- reverse.1
reverse (x:xs)    =  reverse xs ++ [x]    -- reverse.2

length []        =  0                -- length.1
length (_:xs)    =  1 + length xs       -- length.2

sum []        =  0                -- sum.1
sum (x:xs)    =  x + sum xs       -- sum.2

product []        =  1                -- product.1
product (x:xs)    =  x * product xs       -- product.2

replicate 0 _       =  []               -- replicate.1
replicate n x       =  x : replicate (n-1) x  -- replicate.2
