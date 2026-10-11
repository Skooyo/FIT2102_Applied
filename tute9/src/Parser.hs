-- | More Parsers
--
-- We will have a look at more interesting things we can do now that we have
-- the Parser type and Functor and Applicative instances. These exercises will
-- require a combination of many concepts we have seen so far.
--
-- If you get stuck on any of these exercises, feel free to consult the
-- base-64 encoded hints that can be decoded at https://www.base64decode.org/
--
-- Also a reminder that type holes exist and can be quite useful!
--
-- The README contains a list of useful functions and operators worth looking at.
--
-- see https://tgdwyer.github.io/haskell3/#a-simple-applicative-functor-for-parsing
-- (optional) see https://tgdwyer.github.io/parsercombinators/
module Parser
    ( char
    , is
    , isNot
    , string
    , spaces
    , spaces1
    )
where

import Control.Applicative (many, some)
import Data.Char (isSpace)
import Instances (Parser (..), parse)

-- How a Parser works:
--
--   newtype Parser a = Parser (String -> Maybe (String, a))
--
--   A parser is a function. It takes the input and gives:
--     * Nothing             if it fails, or
--     * Just (rest, result) if it succeeds. "rest" is the input it did not use.
--
-- The operators from Instances.hs that we use:
--   f <$> p    run p, then apply f to its result        (Functor)
--   pf <*> p   run pf, then run p on the rest, then apply the function
--              from pf to the result of p               (Applicative)
--   pure x     succeed with x and use no input          (Applicative)
--   p <|> q    run p; if p fails, run q on the SAME input (Alternative)

-- | Parse a single character
char :: Parser Char
-- What: takes the first character of the input.
-- How:  empty input -> fail. Otherwise return the head as the result and the
--   tail as the rest.
--   parse char "abc" = Just ("bc", 'a')
char = Parser f
  where
    f "" = Nothing
    f (x : xs) = Just (xs, x)

-- | Parses a specific character, otherwise return Nothing
--
-- There are better ways to do this, but we won't see it until the
-- later weeks.
is :: Char -> Parser Char
-- What: matches one specific character c.
-- How:  run char. Keep the result only if it is equal to c (the guard
--   "| x == c"). In all other cases, fail.
--   parse (is 'a') "abc" = Just ("bc", 'a')
--   parse (is 'a') "xbc" = Nothing
is c = Parser f
  where
    f i = case parse char i of
        Just (r1, x) | x == c -> Just (r1, x)
        _ -> Nothing

-- | Parses anything except a specific character, otherwise return Nothing
--
-- There are better ways to do this, but we won't see it until the
-- later weeks.
isNot :: Char -> Parser Char
-- What: matches any one character that is NOT c.
-- How:  the same as is, but the guard is "x /= c".
--   parse (isNot '"') "abc" = Just ("bc", 'a')
--   parse (isNot '"') "\"bc" = Nothing
isNot c = Parser f
  where
    f i = case parse char i of
        Just (r1, x) | x /= c -> Just (r1, x)
        _ -> Nothing

-- | Parse a whitespace character
-- This includes more than just the space, but also
-- tabs (\t), \n, \r, \f, \v.
--
-- /Hint/: `isSpace` (check hoogle for what it does)
--
-- There are better ways to do this, but we won't see it until the
-- later weeks.
space :: Parser Char
-- What: matches one whitespace character.
-- How:  the same as is, but the guard is "isSpace x". isSpace is True for
--   ' ', '\t', '\n', '\r', '\f' and '\v'.
space = Parser f
  where
    f i = case parse char i of
        Just (r1, x) | isSpace x -> Just (r1, x)
        _ -> Nothing

-- | Write a function that parses the given string (fails otherwise).
--
-- see: https://tgdwyer.github.io/haskell4/#traversable
--
-- /Hint/: Useful function VXNlIHRyYXZlcnNl
--
-- >>> parse (string "hello") "hello bob"
-- Just (" bob","hello")
-- >>> parse (string "hey") "hello bob"
-- Nothing
string :: String -> Parser String
-- What: matches an exact string, for example "true".
-- How:  traverse :: Applicative f => (a -> f b) -> [a] -> f [b]
--   A String is a list of Char. Here a = Char, f = Parser, b = Char.
--   traverse is "abc" makes one parser for each character
--   (is 'a', is 'b', is 'c'), runs them one after the other with <*>, and
--   collects the results into a list:
--
--     traverse is "abc"
--       = (:) <$> is 'a' <*> ((:) <$> is 'b' <*> ((:) <$> is 'c' <*> pure []))
--
--   If one character does not match, that parser fails, and <*> makes the
--   full parser fail. So string "hey" fails on "hello" at 'y'.
--   Compare with map: map is "abc" gives [Parser Char] (a list of parsers).
--   traverse gives Parser [Char] (one parser for the full string).
string = traverse is

-- | Write a parser that will parse zero or more spaces.
--
-- /Hint/: Remember the `space` parser!
-- /Hint2/: Useful function: bWFueQ==
--
-- >>> parse spaces " abc"
-- Just ("abc"," ")
--
-- >>> parse spaces "abc"
-- Just ("abc","")
spaces :: Parser String
-- What: removes all whitespace at the start of the input.
-- How:  many p runs p again and again until p fails, and collects the results.
--   many p = some p <|> pure []
--   It accepts ZERO matches (the pure [] case), so spaces never fails.
--   parse spaces "  abc" = Just ("abc", "  ")
--   parse spaces "abc"   = Just ("abc", "")
-- Termination: each successful space uses one character, so the input gets
--   shorter every time. Thus many always stops.
spaces = many space

-- | Return a parser that produces one or more space chars (consuming
-- until the first non-space) but fails if:
--
--   * the input is empty; or
--   * the first produced char is not a space.
--
-- /Hint/: Useful function: c29tZQ==
-- >>> parse spaces1 " abc"
-- Just ("abc"," ")
--
-- >>> parse spaces1 "abc"
-- Nothing
spaces1 :: Parser String
-- What: the same as spaces, but needs ONE OR MORE whitespace characters.
-- How:  some p = (:) <$> p <*> many p
--   The first p must succeed, so "abc" fails.
--   many vs some is the same difference as sepBy vs sepBy1 in JSON.hs.
spaces1 = some space
