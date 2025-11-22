{-# LANGUAGE StandaloneDeriving #-}

module Main where

import Ex3
import Test.Framework as TF (Test, defaultMain, testGroup)
import Test.Framework.Providers.HUnit (testCase)
import Test.HUnit
import Test3Support

main = defaultMain tests

tests :: [TF.Test]
tests =
  [ testGroup
      "Q1 eval basic arithmetic"
      [ testCase "LitNum returns its value" $
          let d = [] in eval d (LitNum 3.5) @?= 3.5,
        testCase "Ident looks up in dict" $
          let d = insert "x" 2.0 [] in eval d (Ident "x") @?= 2.0,
        testCase "Sum adds literals and identifiers" $
          let d = insert "x" 2.0 [] in eval d (Sum (LitNum 3.0) (Ident "x")) @?= 5.0,
        testCase "AddInv negates the value" $
          let d = [] in eval d (AddInv (LitNum 3.0)) @?= (-3.0),
        testCase "Div divides correctly" $
          let d = [] in eval d (Div (LitNum 10.0) (LitNum 2.0)) @?= 5.0
      ],
    testGroup
      "Q1 eval boolean semantics (0.0 is False, nonzero is True)"
      [ testCase "Not 0.0 -> 1.0" $
          let d = [] in eval d (Not (LitNum 0.0)) @?= 1.0,
        testCase "Not nonzero -> 0.0" $
          let d = [] in eval d (Not (LitNum 42.0)) @?= 0.0,
        testCase "GrtOrEq true when left >= right" $
          let d = [] in eval d (GrtOrEq (LitNum 3.0) (LitNum 2.0)) @?= 1.0,
        testCase "GrtOrEq false when left < right" $
          let d = [] in eval d (GrtOrEq (LitNum 2.0) (LitNum 3.0)) @?= 0.0,
        testCase "GrtOrEq true when equal" $
          let d = [] in eval d (GrtOrEq (LitNum 2.0) (LitNum 2.0)) @?= 1.0,
        testCase "EqToZero true for 0.0" $
          let d = [] in eval d (EqToZero (LitNum 0.0)) @?= 1.0,
        testCase "EqToZero false for nonzero" $
          let d = [] in eval d (EqToZero (LitNum 0.1)) @?= 0.0
      ],
    testGroup
      "Q1 eval composed expression"
      [ testCase "Not (x - 2 == 0) with x=2 -> 0.0" $
          let d = insert "x" 2.0 []; expr = Not (EqToZero (Sum (Ident "x") (AddInv (LitNum 2.0))))
           in eval d expr @?= 0.0
      ],
    testGroup
      "Q2 meval (Maybe evaluation)"
      [ testCase "LitNum -> Just value" $
          let d = [] in meval d (LitNum 3.5) @?= Just 3.5,
        testCase "Ident present -> Just value" $
          let d = insert "x" 2.0 [] in meval d (Ident "x") @?= Just 2.0,
        testCase "Ident missing -> Nothing" $
          let d = [] in meval d (Ident "x") @?= Nothing,
        testCase "Sum -> Just sum" $
          let d = insert "x" 2.0 [] in meval d (Sum (LitNum 3.0) (Ident "x")) @?= Just 5.0,
        testCase "AddInv -> Just negated" $
          let d = [] in meval d (AddInv (LitNum 3.0)) @?= Just (-3.0),
        testCase "Div normal -> Just quotient" $
          let d = [] in meval d (Div (LitNum 10.0) (LitNum 2.0)) @?= Just 5.0,
        testCase "Div by zero -> Nothing" $
          let d = [] in meval d (Div (LitNum 1.0) (LitNum 0.0)) @?= Nothing,
        testCase "Not 0.0 -> Just 1.0" $
          let d = [] in meval d (Not (LitNum 0.0)) @?= Just 1.0,
        testCase "Not nonzero -> Just 0.0" $
          let d = [] in meval d (Not (LitNum 7.0)) @?= Just 0.0,
        testCase "GrtOrEq true when left >= right -> Just 1.0" $
          let d = [] in meval d (GrtOrEq (LitNum 3.0) (LitNum 2.0)) @?= Just 1.0,
        testCase "GrtOrEq false when left < right -> Just 0.0" $
          let d = [] in meval d (GrtOrEq (LitNum 2.0) (LitNum 3.0)) @?= Just 0.0,
        testCase "EqToZero true for 0.0 -> Just 1.0" $
          let d = [] in meval d (EqToZero (LitNum 0.0)) @?= Just 1.0,
        testCase "EqToZero false for nonzero -> Just 0.0" $
          let d = [] in meval d (EqToZero (LitNum 0.1)) @?= Just 0.0,
        testCase "Error in subexpression propagates: Not (Div 1 0) -> Nothing" $
          let d = [] in meval d (Not (Div (LitNum 1.0) (LitNum 0.0))) @?= Nothing,
        testCase "Sum with error on left -> Nothing" $
          let d = [] in meval d (Sum (Div (LitNum 1.0) (LitNum 0.0)) (LitNum 2.0)) @?= Nothing,
        testCase "Composed expression succeeds -> Just 0.0" $
          let d = insert "x" 2.0 []
              expr = Not (EqToZero (Sum (Ident "x") (AddInv (LitNum 2.0))))
           in meval d expr @?= Just 0.0
      ],
    testGroup
      "Q3 simp (use only x+0=x and 0+x=x)"
      [ testCase "x + 0 -> x" $
          let x = Ident "x"; expr = Sum x (LitNum 0.0)
           in simp expr @?= x,
        testCase "0 + x -> x" $
          let x = Ident "x"; expr = Sum (LitNum 0.0) x
           in simp expr @?= x,
        testCase "nested: 0 + (x + 0) -> x" $
          let x = Ident "x"; expr = Sum (LitNum 0.0) (Sum x (LitNum 0.0))
           in simp expr @?= x,
        testCase "no change when no 0 addends" $
          let x = Ident "x"; expr = Sum (LitNum 1.0) x
           in simp expr @?= expr,
        testCase "simplifies inside larger expr" $
          let x = Ident "x"; expr = Not (EqToZero (Sum (LitNum 0.0) x)); expected = Not (EqToZero x)
           in simp expr @?= expected,
        testCase "multiple zeros: (0 + (0 + x)) + 0 -> x" $
          let x = Ident "x"; expr = Sum (Sum (LitNum 0.0) (Sum (LitNum 0.0) x)) (LitNum 0.0)
           in simp expr @?= x
      ]
  ]
