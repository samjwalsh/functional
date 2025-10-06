module Ex2 where

rollover :: Int
rollover = 1000000000

add :: Int -> Int -> Int
add x y = (x + y) `mod` rollover

mul :: Int -> Int -> Int
mul x y
  | p == 0 = 1
  | otherwise = p
  where
    p = (x * y) `mod` rollover

-- DON'T RENAME THE SPECIFIED TYPES OR FUNCTIONS
-- DON'T MODIFY ANYTHING ABOVE THIS LINE

-- *** Q1,2,3 (8 marks)

-- Hint for Q1,2,3: taking every 3rd element of [1..13] returns [3,6,9,12]

-- *** Q1

-- returns a list of every 333rd element of its input
f1 :: [a] -> [a] -- DO NOT CHANGE !
f1 xs = case drop 332 xs of
  [] -> []
  (y : ys) -> y : f1 ys

-- *** Q2

-- sums every 137th element of its input
-- if list is too short it returns 0
-- you can use `add` or `(+)` here - won't effect grading
f2 :: [Int] -> Int -- DO NOT CHANGE !
f2 ns = case drop 136 ns of
  [] -> 0
  (x : xs) -> add x (f2 xs)

-- *** Q3

-- multiplies every 278th element of its input
-- if list is too short it returns 1
-- you can use `mul` or `(*)` here - won't effect grading
f3 :: [Int] -> Int -- DO NOT CHANGE !
f3 ns = case drop 277 ns of
  [] -> 1
  (x : xs) -> mul x (f3 xs)

-- *** Q4 (9 marks)

-- Operation Table (See Exercise2 description on BB)
--    ____________________________________________
--    | opcode | operation | operands  | Nothing |
--    --------------------------------------------
--    |   73   |    add    | fixed  5  | term    |
--    |   86   |    add    | fixed  6  | skip    |
--    |   93   |    add    | fixed  4  | 1       |
--    |   17   |    add    | stop@ 16  | term    |
--    |   59   |    add    | stop@ 13  | skip    |
--    |   28   |    add    | stop@ 15  | 8       |
--    |   36   |    mul    | fixed  3  | term    |
--    |   66   |    mul    | fixed  6  | skip    |
--    |   91   |    mul    | fixed  4  | 1       |
--    |   76   |    mul    | stop@ 16  | term    |
--    |   97   |    mul    | stop@ 15  | skip    |
--    |   95   |    mul    | stop@ 14  | 2       |
--    --------------------------------------------
-- initially, skip any number that is not an opcode
-- if called with [], return `(0,[])`
-- if no numbers found after an `add` opcode, return (0,[])
-- if no numbers found after an `mul` opcode, return (1,[])
-- if list ends midway through opcode processing, return result so far
-- if a Nothing is skipped for a fixed N opcode,
--    that Nothing does not contribute to the count.
-- Hint:
--   When building a list for test purposes,
--   remember a value of type `Maybe a` needs to be built
--   using one of the two data constructors of the `Maybe` type.

f4 :: [Maybe Int] -> (Int, [Maybe Int]) -- DO NOT CHANGE !
f4 [] = (0, [])
f4 (mi : mis) =
  case mi of
    Just 73 -> processFixed add 0 5 Term mis
    Just 86 -> processFixed add 0 6 Skip mis
    Just 93 -> processFixed add 0 4 (Default 1) mis
    Just 17 -> processStop add 0 16 Term mis
    Just 59 -> processStop add 0 13 Skip mis
    Just 28 -> processStop add 0 15 (Default 8) mis
    Just 36 -> processFixed mul 1 3 Term mis
    Just 66 -> processFixed mul 1 6 Skip mis
    Just 91 -> processFixed mul 1 4 (Default 1) mis
    Just 76 -> processStop mul 1 16 Term mis
    Just 97 -> processStop mul 1 15 Skip mis
    Just 95 -> processStop mul 1 14 (Default 2) mis
    _ -> f4 mis

data NothingAction = Term | Skip | Default Int

processFixed :: (Int -> Int -> Int) -> Int -> Int -> NothingAction -> [Maybe Int] -> (Int, [Maybe Int])
processFixed _ acc 0 _ rest = (acc, rest)
processFixed _ acc _ _ [] = (acc, [])
processFixed op acc n na (mi : mis) =
  case mi of
    Just x -> processFixed op (op acc x) (n - 1) na mis
    Nothing -> case na of
      Term -> (acc, mis)
      Skip -> processFixed op acc n na mis
      Default d -> processFixed op (op acc d) (n - 1) na mis

processStop :: (Int -> Int -> Int) -> Int -> Int -> NothingAction -> [Maybe Int] -> (Int, [Maybe Int])
processStop _ acc _ _ [] = (acc, [])
processStop op acc stopVal na (mi : mis) =
  case mi of
    Just x
      | x == stopVal -> (acc, mis)
      | otherwise -> processStop op (op acc x) stopVal na mis
    Nothing -> case na of
      Term -> (acc, mis)
      Skip -> processStop op acc stopVal na mis
      Default d -> processStop op (op acc d) stopVal na mis

-- *** Q5 (3 marks)

-- uses `f4` to process all the opcodes in the maybe list,
-- by repeatedly applying it to the leftover part
-- Note: this will be tested against a correct version of `f4`,
-- f5 keeps calling f4 as long as there is a non-empty rest list.
-- • f5 [42,2,4,6,24,2,4,6,2,0,99,2,4,6,2,99] = [12,96,14]
-- • f5 [42,2,X,6,24,2,6,2,2,99,2,4,6,2,99] = [2,7527168]
-- I never claimed this mythical processor was perfect!
f5 :: [Maybe Int] -> [Int] -- DO NOT CHANGE !
f5 l =
  case dropWhile (not . isAnOpcode) l of
    [] -> []
    l' ->
      let (r, rest) = f4 l'
       in r : f5 rest
  where
    isAnOpcode :: Maybe Int -> Bool
    isAnOpcode (Just x) = x `elem` [73, 86, 93, 17, 59, 28, 36, 66, 91, 76, 97, 95]
    isAnOpcode Nothing = False

-- add extra material below here
-- e.g.,  helper functions, test values, etc. ...
