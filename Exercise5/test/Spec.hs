{-# LANGUAGE StandaloneDeriving #-}
module Main where
import Test.HUnit
import Test.Framework as TF (defaultMain, testGroup, Test)
import Test.Framework.Providers.HUnit (testCase)
import Ex5
main = defaultMain tests
tests :: [TF.Test]
tests = 
  [ testGroup "TEST Ex5" [
      testCase "Ex5 2+2=5" (2+2 @?= 5)
  ] ]

