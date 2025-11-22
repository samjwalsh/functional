module Ex4 where

-- no code for Q1


-- for Q2:
rec2ursFunc x  =  if x <= 8 then 6 else x + rec2ursFunc (x - 5)



-- for Q3:
c0ompute []      =  2
c0ompute (x:xs)  =  x + 17 + c0ompute xs




--for Q4:
d3oubling x
  | x < 5   =  2*x
  | x >= 5  = 2*x-1


