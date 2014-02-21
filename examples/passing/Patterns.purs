module Patterns where

  import Prelude

  test = \x -> case x of 
    { str = "Foo", bool = true } -> true
    { str = "Bar", bool = b } -> b
    _ -> false

  f = \o -> case o of
    { foo = "Foo" } -> o.bar
    _ -> 0

  g = \o -> case o of
    { arr = [x : xs], take = "car" } -> x
    { arr = [_, x : xs], take = "cadr" } -> x
    _ -> 0


  h = \o -> case o of 
    a@[_,_,_] -> a
    _ -> []

  isDesc :: [Number] -> Boolean
  isDesc [x, y] | x > y = true
  isDesc _ = false
    
module Main where

main = Debug.Trace.trace "Done"
