{-# LANGUAGE StandaloneDeriving #-}
module Main where
import Test.HUnit
import Test.Framework as TF (defaultMain, testGroup, Test)
import Test.Framework.Providers.HUnit (testCase)
import Ex3
import Test3Support
main = defaultMain tests
tests :: [TF.Test]
tests = 
  [ testGroup "TEST Ex3" [
      testCase "Ex1 2+2=5" (2+2 @?= 5)
  ] ]

