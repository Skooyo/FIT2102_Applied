{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE NoImplicitPrelude #-}

-- | The goal of this module is to rewrite "standard" Haskell functions using
-- only /folds/.
module Folds (all, any, sum, product, length, (++), flatten, Tree (..)) where

import Prelude hiding (all, any, length, product, sum, (++))

-- How foldr works (all functions in this file use it):
--
--   foldr :: (a -> b -> b) -> b -> [a] -> b
--   foldr f z [x1, x2, x3] = f x1 (f x2 (f x3 z))
--
--   * z is the start value. It replaces the empty list [] at the end.
--   * f replaces each cons (:). It gets one element and the result for
--     the rest of the list.
--
-- So each function below only has to choose f and z.
-- Point-free means we do not name the list argument. "all = foldr (&&) True"
-- is the same as "all xs = foldr (&&) True xs", with xs removed from both sides.

-- | Rewrite 'all' using 'foldr'.
-- | Must write point-free and without lambda functions.
-- >>> all [True, True, True]
-- True
--
-- >>> all [False, True, True]
-- False
all :: [Bool] -> Bool
-- What: True only if every element is True.
-- How:  f = (&&), z = True
--   all [a, b, c] = a && (b && (c && True))
-- Why True: True is the identity of (&&), because x && True == x.
--   So all [] == True (there is no element that is False).
-- Laziness: (&&) does not look at its right side when the left side is False.
--   So the fold stops at the first False and does not read the rest of the list.
all = foldr (&&) True

-- | Rewrite 'any' using 'foldr'.
-- | Must write point-free and without lambda functions.
-- >>> any [False, False, False]
-- False
--
-- >>> any [False, True, False]
-- True
any :: [Bool] -> Bool
-- What: True if one or more elements are True.
-- How:  f = (||), z = False
--   any [a, b, c] = a || (b || (c || False))
-- Why False: False is the identity of (||), because x || False == x.
--   So any [] == False (there is no element that is True).
-- Laziness: (||) stops at the first True.
any = foldr (||) False

-- | Rewrite 'sum' using 'foldr'.
-- | Must write point-free and without lambda functions.
-- >>> sum [1, 2, 3]
-- 6
--
-- >>> sum [1..10]
-- 55
--
-- prop> \x -> foldl (-) (sum x) x == 0
sum :: Num a => [a] -> a
-- What: adds all the elements.
-- How:  f = (+), z = 0
--   sum [1, 2, 3] = 1 + (2 + (3 + 0)) = 6
-- Why 0: 0 is the identity of (+), because x + 0 == x. So sum [] == 0.
sum = foldr (+) 0

-- | Rewrite 'product' using 'foldr'.
-- | Must write point-free and without lambda functions.
-- >>> product [1, 2, 3]
-- 6
--
-- >>> product [1..10]
-- 3628800
product :: Num a => [a] -> a
-- What: multiplies all the elements.
-- How:  f = (*), z = 1
--   product [1, 2, 3] = 1 * (2 * (3 * 1)) = 6
-- Why 1: 1 is the identity of (*), because x * 1 == x.
--   If z were 0, every product would be 0.
product = foldr (*) 1

-- | Rewrite 'length' using 'foldr'.
-- | Must write point-free and without lambda functions.
-- >>> length [1, 2, 3]
-- 3
--
-- >>> length []
-- 0
--
-- prop> sum (map (const 1) x) == length x
length :: [a] -> Int
-- What: counts the elements.
-- How:  f = const (+1), z = 0
--
-- The role of const:
--   foldr needs f :: a -> Int -> Int. f gets the element and the count for
--   the rest of the list. To count, f must IGNORE the element and add 1
--   to the count.
--
--   const :: a -> b -> a
--   const x _ = x          -- returns its first argument, ignores the second
--
--   Here the first argument of const is the FUNCTION (+1). So:
--     const (+1) elem      = (+1)          -- the element is ignored
--     const (+1) elem acc  = (+1) acc = acc + 1
--
--   So const (+1) does the same work as the lambda (\_ acc -> acc + 1),
--   but with no lambda and no named arguments. This keeps it point-free.
--
--   length [7, 8, 9] = (+1) ((+1) ((+1) 0)) = 3
--   length []        = 0                     -- only z is left
length = foldr (const (+ 1)) 0

-- | Rewrite /append/ '(++)' using 'foldr'.
-- | Must write this in point-free notation and without lambda functions
--
-- /Hint/: This is the same as cons-ing the elements of the first list to the second
-- /Hint/: The 'flip' function might come in handy
--
-- >>> [1] ++ [2] ++ [3]
-- [1,2,3]
--
-- >>> "abc" ++ "d"
-- "abcd"
--
-- prop> (x ++ []) == x
--
-- Associativity of append.
-- prop> (x ++ y) ++ z == x ++ (y ++ z)
(++) :: [a] -> [a] -> [a]
-- What: puts the second list after the first list.
-- How:  f = (:), z = the second list
--   foldr (:) ys [x1, x2] = x1 : (x2 : ys)
--   This puts each element of the first list in front of ys. That is append.
-- Why flip:
--   foldr (:) takes z (ys) FIRST and the folded list (xs) SECOND.
--   But xs ++ ys takes xs first. flip swaps the two arguments:
--     flip g a b = g b a
--     xs ++ ys   = flip (foldr (:)) xs ys = foldr (:) ys xs
--   Without flip, "abc" ++ "d" gives "dabc".
(++) = flip (foldr (:))

-- | Flatten a (once) nested list.
-- | Must write point-free and without lambda functions.
-- >>> flatten [[1], [2], [3]]
-- [1,2,3]
--
-- >>> flatten [[1, 2], [3], []]
-- [1,2,3]
--
-- prop> sum (map length x) == length (flatten x)
flatten :: [[a]] -> [a]
-- What: joins a list of lists into one list.
-- How:  f = (++), z = []
--   flatten [[1, 2], [3], []] = [1, 2] ++ ([3] ++ ([] ++ [])) = [1, 2, 3]
-- Why []: [] is the identity of (++), because xs ++ [] == xs.
-- Note: this (++) is OUR (++) above, because the Prelude one is hidden.
flatten = foldr (++) []

-- | A binary tree with data only at the leaves
-- | NOTE: This tree definition is different compared to previous weeks!
data Tree a = Leaf a | Node (Tree a) (Tree a)
    deriving (Show)

-- | Instance of Foldable for binary Tree
-- see: https://tgdwyer.github.io/haskell4/#monoid
--
-- foldMap accumulates the result in a Monoid.  The aggregative operator for Monoid is (<>)
--
-- >>> import Data.Monoid
-- >>> let t = (Node (Node (Leaf 1) (Leaf 2)) (Node (Leaf 3) (Leaf 4)))
-- >>> foldMap Sum t
-- Sum {getSum = 10}
--
-- >>> foldr (+) 0 t
-- 10
instance Foldable Tree where
    foldMap :: Monoid m => (a -> m) -> Tree a -> m
    -- What: change every leaf value into a Monoid value with f, then join
    --   all of them with (<>).
    -- How (recursion on the shape of the tree):
    --   Leaf: there is one value. Change it with f.
    --   Node: fold the left subtree, fold the right subtree, join with (<>).
    --
    --   foldMap Sum (Node (Leaf 1) (Leaf 2)) = Sum 1 <> Sum 2 = Sum 3
    --
    -- The Monoid decides what "join" means:
    --   Sum -> add, Product -> multiply, [a] -> append, All -> (&&).
    --
    -- We only write foldMap. Haskell makes foldr, sum, length, elem, and the
    -- other Foldable functions from it. That is why "foldr (+) 0 t" works.
    foldMap f (Leaf a) = f a
    foldMap f (Node l r) = foldMap f l <> foldMap f r
