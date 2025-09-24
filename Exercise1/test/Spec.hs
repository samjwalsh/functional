{-# LANGUAGE StandaloneDeriving #-}
module Main where
import Test.HUnit
import Test.Framework as TF (defaultMain, testGroup, Test)
import Test.Framework.Providers.HUnit (testCase)
import Ex1
main = defaultMain tests
tests :: [TF.Test]
tests = 
  [ testGroup "TEST Ex1" [
      testCase "Ex1 div-by-zero" (100/0 @?= 100)
    , testCase "Ex1 undefined" (head [] @?= 42)
    , testCase "Ex1 2+2=5" (2+2 @?= 5)
    , testCase "Ex1 1+1=2" (1+1 @?= 2)
  ] ]

