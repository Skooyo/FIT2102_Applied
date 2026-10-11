-- | Implement a limited JSON parser.
--
-- Use the provided JsonValue type to create a parser for JSON values.
-- A good starting point is to consider how to parse the literal types
-- such as JTrue, JFalse, JNull, JInteger, and JString.
--
-- Make sure to refer to Instances.hs and Parser.hs for utility functions,
-- parsers, and parser combinators to help you.
--
-- **Reminders**
-- You must NOT manually construct the Parser type using the Parser constructor,
-- nor use the `parse` function to chain together parsers. You must also NOT
-- use the `reads` function or equivalent. The cases where this is the
-- intended solution have already been provided to you.
--
-- The README contains a list of useful functions and operators worth looking at.
--
-- see https://tgdwyer.github.io/parsercombinators/#a-parser-that-returns-an-adt
module JSON (json, sepBy, JsonValue (..), tok, isTok, stringTok) where

import Control.Applicative (many, (<|>))
import Data.Foldable (asum)
import Instances (Parser (..), int)
import Parser (is, isNot, spaces, string)

-- Operators used in this file (Parser has no Monad instance, so we only use
-- Functor, Applicative and Alternative):
--
--   f <$> p     run p, apply f to the result
--   x <$ p      run p, ignore its result, return x
--   p *> q      run p then q, keep the result of q   (drop the left side)
--   p <* q      run p then q, keep the result of p   (drop the right side)
--   f <$> p <*> q   run p then q, give both results to f
--   p <|> q     run p; if p fails, run q on the SAME input
--   pure x      succeed with x, use no input
--
-- Whitespace rule: every token parser removes the spaces AFTER itself (tok).
-- So every parser can assume that its input does not start with a space.

-- $setup
-- >>> import Instances (parse)

type KeyVal = (String, JsonValue)

-- | JSON value representation.
data JsonValue
    = JInteger Int
    | JString String
    | JObject [KeyVal]
    | JArray [JsonValue]
    | JTrue
    | JFalse
    | JNull
    deriving (Show, Eq)

-- | Write a function that applies the given parser, then
--  zero or more space characters.
--
-- >>> parse (tok (is 'a')) "a bc"
-- Just ("bc",'a')
--
-- >>> parse (tok (is 'a')) "abc"
-- Just ("bc",'a')
tok :: Parser a -> Parser a
-- What: run p, then remove the whitespace after it.
-- How:  p <* spaces runs p, then spaces, and keeps only the result of p.
--   spaces accepts zero spaces, so tok p never fails because of spaces.
tok p = p <* spaces

-- | Write a function that parses the given char followed by 0 or more spaces.
--
-- /Hint/: Remember the `is` parser
--
-- >>> parse (isTok 'a') "abc"
-- Just ("bc",'a')
--
-- >>> parse (isTok 'a') "dabc"
-- Nothing
isTok :: Char -> Parser Char
-- What: match the character c, then remove the spaces after it.
-- How:  function composition. (tok . is) c = tok (is c).
isTok = tok . is

-- | Write a function that parses a comma followed by 0 or more spaces.
--
-- /Hint/: Remember the `is` parser
--
-- >>> parse commaTok ", bc"
-- Just ("bc",',')
--
-- >>> parse commaTok "dabc"
-- Nothing
commaTok :: Parser Char
-- What: match ',' and the spaces after it. This is the separator in arrays
--   and objects.
commaTok = isTok ','

-- | Write a function that parses the given string, followed by 0 or more
-- spaces.
--
-- /Hint/: Remember the `string` parser
--
-- >>> parse (stringTok "abc") "abc  "
-- Just ("","abc")
--
-- >>> parse (stringTok "abc") "bc  "
-- Nothing
stringTok :: String -> Parser String
-- What: match the exact string s, then remove the spaces after it.
-- How:  (tok . string) s = tok (string s).
stringTok = tok . string

-- | Parse a JSON integer.
--
-- >>> parse jsonInteger "234"
-- Just ("",JInteger 234)
--
-- >>> parse jsonInteger "-234"
-- Just ("",JInteger (-234))
--
-- >>> parse jsonInteger "-123.45"
-- Nothing
--
-- >>> parse jsonInteger "-"
-- Nothing
--
-- >>> parse jsonInteger "abc"
-- Nothing
jsonInteger :: Parser JsonValue
-- What: read an Int and put it in the JInteger constructor.
-- How:  int (given in Instances.hs) gives Parser Int. JInteger :: Int -> JsonValue,
--   so JInteger <$> changes Parser Int into Parser JsonValue.
--   int reads the full number token, so "-123.45" is not an Int and fails.
--   "-" and "abc" have no digits, so they also fail.
jsonInteger = JInteger <$> tok int

-- | Parse a JSON true literal.
-- /Hint/ Useful function PCQ=
--
-- >>> parse jsonTrue "true"
-- Just ("",JTrue)
--
-- >>> parse jsonTrue "TRUE"
-- Nothing
jsonTrue :: Parser JsonValue
-- What: match the text "true" and return JTrue.
-- How:  stringTok "true" gives the String "true". We do not need that string,
--   only the constructor. x <$ p runs p and replaces its result with x.
--   (The hint PCQ= is base64 for "<$".)
--   string is case-sensitive, so "TRUE" fails.
jsonTrue = JTrue <$ stringTok "true"

-- | Parse a JSON false literal.
--
-- >>> parse jsonFalse "false"
-- Just ("",JFalse)
--
-- >>> parse jsonFalse "FALSE"
-- Nothing
jsonFalse :: Parser JsonValue
-- What: match "false" and return JFalse. The same method as jsonTrue.
jsonFalse = JFalse <$ stringTok "false"

-- | Parse a JSON boolean.
--
-- >>> parse jsonBool "false"
-- Just ("",JFalse)
--
-- >>> parse jsonBool "true"
-- Just ("",JTrue)
--
-- >>> parse jsonBool "TRUE"
-- Nothing
jsonBool :: Parser JsonValue
-- What: match true or false.
-- How:  <|> tries jsonTrue. If it fails, it tries jsonFalse on the same input.
--   This is the BNF rule <Bool> ::= <True> | <False>.
jsonBool = jsonTrue <|> jsonFalse

-- | Parse a JSON null literal.
--
-- >>> parse jsonNull "null"
-- Just ("",JNull)
--
-- >>> parse jsonNull "NULL"
-- Nothing
jsonNull :: Parser JsonValue
-- What: match "null" and return JNull. The same method as jsonTrue.
jsonNull = JNull <$ stringTok "null"

-- | Parse a sequence of at least one values with a separator.
--
-- >>> parse ((isTok 'a') `sepBy1` commaTok) ""
-- Nothing
--
-- >>> parse ((isTok 'a') `sepBy1` commaTok) "a"
-- Just ("","a")
--
-- >>> parse ((isTok 'a') `sepBy1` commaTok) "a,a"
-- Just ("","aa")
--
-- >>> parse ((tok int) `sepBy1` commaTok) "1,2,3"
-- Just ("",[1,2,3])
sepBy1 :: Parser a -> Parser b -> Parser [a]
-- What: read ONE OR MORE items p with a separator sep between them.
-- How:  the input looks like:  p  (sep p)  (sep p)  ...
--   1. p                  reads the first item. It must succeed.
--   2. many (sep *> p)    reads zero or more "separator, item" pairs.
--                         *> drops the separator and keeps the item.
--   3. <:>                conses the first item onto the list from step 2.
--
--   "1,2,3": p gives 1, many gives [2, 3], <:> gives [1, 2, 3].
--
--   If a separator has no item after it ("a,a,"), that pair fails as a whole,
--   so many stops BEFORE the last ',' and leaves it in the rest.
sepBy1 p sep = p <:> many (sep *> p)
  where
    -- (Optional) cons the results of two parsers
    (<:>) :: Parser a -> Parser [a] -> Parser [a]
    -- Run a, then as, then cons the two results with (:).
    a <:> as = (:) <$> a <*> as

-- | Parse a sequence of values with a separator.
--
-- >>> parse ((isTok 'a') `sepBy` commaTok) ""
-- Just ("","")
--
-- >>> parse ((isTok 'a') `sepBy` commaTok) "a"
-- Just ("","a")
--
-- >>> parse ((isTok 'a') `sepBy` commaTok) "a,a"
-- Just ("","aa")
--
-- >>> parse ((tok int) `sepBy` commaTok) "1,2,3"
-- Just ("",[1,2,3])
sepBy :: Parser a -> Parser b -> Parser [a]
-- What: read ZERO OR MORE items with a separator between them.
-- How:  try sepBy1. If it fails (no first item), pure [] succeeds with an
--   empty list and uses no input. So sepBy never fails.
--   This is why "[]" and "{}" work in jsonArray and jsonObject.
--   sepBy1 vs sepBy is the same difference as some vs many.
sepBy p sep = sepBy1 p sep <|> pure []

-- | A quoteString is any series of any non-" characters surrounded by " "
--
-- >>> parse quoteString "\" abc\""
-- Just (""," abc")
--
-- >>> parse quoteString "\"abc\"def"
-- Just ("def","abc")
--
-- >>> parse quoteString "abc"
-- Nothing
--
-- >>> parse quoteString "\"\\abc\"def"
-- Just ("def","\\abc")
quoteString :: Parser String
-- What: read the text between two double quotes, without the quotes.
-- How:  1. is '"'              match the opening quote (dropped by *>)
--       2. many (isNot '"')    read every character that is not a quote
--       3. is '"'              match the closing quote (dropped by <*)
--   Only the result of step 2 stays.
--   A backslash is not a quote, so "\\abc" passes as normal text.
--   This does not handle escaped quotes (\"). That is OK for this limited parser.
--   No tok here, because a space inside the quotes is part of the string.
quoteString = is '"' *> many (isNot '"') <* is '"'

-- | Parse a JSON string. Handle double-quotes.
--
-- >>> parse jsonString "\" abc\""
-- Just ("",JString " abc")
--
-- >>> parse jsonString "\"abc\"def"
-- Just ("def",JString "abc")
--
-- >>> parse jsonString "abc"
-- Nothing
--
-- >>> parse jsonString "\"\\abc\"def"
-- Just ("def",JString "\\abc")
jsonString :: Parser JsonValue
-- What: read a quoted string and put it in JString.
-- How:  tok quoteString reads the string and removes the spaces AFTER the
--   closing quote. JString <$> wraps the result.
jsonString = JString <$> tok quoteString

-- | Parse a JSON array.
--
-- /Hint/: Remember the type [JsonValue] means a list of JsonValues, and the
--  parser for JsonValue is called json.
--
-- /Hint 2/: This parser is co-recursive!
-- To test this parser, you will need to implement
-- the json function (at end of this file) as well
--
-- see https://tgdwyer.github.io/parsercombinators/#creating-a-parse-tree
--
-- >>> parse jsonArray "[]"
-- Just ("",JArray [])
--
-- >>> parse jsonArray "[true]"
-- Just ("",JArray [JTrue])
--
-- >>> parse jsonArray "[true, 5, []]"
-- Just ("",JArray [JTrue,JInteger 5,JArray []])
jsonArray :: Parser JsonValue
-- What: read "[ value, value, ... ]" and return JArray [values].
-- How:  BNF: <Array> ::= '[' <ArrayContents> ']' | '[' ']'
--   1. isTok '['               match '[' (dropped by *>)
--   2. sepBy json commaTok     zero or more JSON values with commas between
--   3. isTok ']'               match ']' (dropped by <*)
--   JArray <$> wraps the list from step 2.
--
-- Co-recursion and why it does not loop forever:
--   jsonArray calls json, and json calls jsonArray (through jsonContainer).
--   This is safe for two reasons:
--
--   1. Input is used BEFORE each recursive call.
--      jsonArray must match '[' before it calls json. So each nested level
--      works on a shorter input than the level above it. The input is finite,
--      so the nesting must stop. A loop happens only with LEFT recursion,
--      where a parser calls itself before it uses any input, for example
--        bad = (++) <$> bad <*> string "a"   -- loops forever
--      Our grammar has no left recursion: every path from json back to json
--      first matches '[' or '{' (and for objects, a key and ':').
--
--   2. Haskell is lazy.
--      A Parser is a function that waits for input. Defining json in terms of
--      jsonArray (and the reverse) only builds functions. Nothing runs until
--      parse gives the parser an input. Then each recursive call happens only
--      when the parser reaches a '[' or '{' in the input.
--
--   Also, every many in this file uses input on each success (isNot '"' uses
--   one char, sep *> p uses at least a ','), so no many can loop forever.
--
--   Example: "[[]]"
--     jsonArray matches '['   -> rest "[]]"
--     json -> jsonArray matches '[' -> rest "]]"
--       json fails on "]", so sepBy gives [] -> ']' -> rest "]"
--     ']' -> rest ""           result: JArray [JArray []]
jsonArray = JArray <$> (isTok '[' *> sepBy json commaTok <* isTok ']')

-- | Parse a JSON object.
--
-- /Hint/: Remember the type KeyVal = [(String, JsonValue)].
--
-- /Hint 2/: This parser is also co-recursive!
--  To test this parser, you will need to implement the json function as well.
--
-- >>> parse jsonObject "{}"
-- Just ("",JObject [])
--
-- >>> parse jsonObject "{ \"key1\" : true }"
-- Just ("",JObject [("key1",JTrue)])
--
-- >>> parse jsonObject "{ \"key1\" : true , \"key2\" : false }"
-- Just ("",JObject [("key1",JTrue),("key2",JFalse)])
--
-- >>> parse jsonObject "{ \"key1\" : true , \"key2\" : false } xyz"
-- Just ("xyz",JObject [("key1",JTrue),("key2",JFalse)])
jsonObject :: Parser JsonValue
-- What: read "{ key: value, key: value, ... }" and return JObject [(key, value)].
-- How:  the same method as jsonArray, with '{' '}' and kv items.
--   isTok '}' removes the spaces after the object, so "{...} xyz" leaves "xyz".
--   It is co-recursive through kv -> json. It cannot loop forever for the same
--   reason as jsonArray: '{', a key and ':' are used before json is called.
jsonObject = JObject <$> (isTok '{' *> sepBy kv commaTok <* isTok '}')
  where
    kv :: Parser (String, JsonValue)
    -- What: read one "key : value" pair. BNF: <Pair> ::= <String> ':' <JSON>
    -- How:  1. tok quoteString   the key (with the spaces after it)
    --       2. isTok ':'         the colon (dropped by <*)
    --       3. json              the value (can be nested)
    --   (,) is the tuple constructor. (,) <$> key <*> value makes (key, value).
    kv = (,) <$> tok quoteString <* isTok ':' <*> json

-- | Parse a JSON value
-- Either a Boolean, Integer, String, Null
--
-- >>> parse jsonVal "\" abc\""
-- Just ("",JString " abc")
--
-- >>> parse jsonVal "false"
-- Just ("",JFalse)
--
-- >>> parse jsonVal "234"
-- Just ("",JInteger 234)
--
-- >>> parse jsonVal "null"
-- Just ("",JNull)
jsonVal :: Parser JsonValue
-- What: read one simple value (not an array or object).
-- How:  asum [p1, p2, p3, p4] = p1 <|> p2 <|> p3 <|> p4.
--   It tries each parser on the same input. The first success wins.
--   The order does not change the result here, because each value starts
--   with a different character: digit or '-', '"', 't'/'f', 'n'.
--   BNF: <JSONVal> ::= <Integer> | <Null> | <Bool> | <String>
jsonVal = asum [jsonInteger, jsonString, jsonBool, jsonNull]

-- | Parse a JSON container, either an array or an object.
--
-- >>> parse jsonContainer "[true, 5, []]"
-- Just ("",JArray [JTrue,JInteger 5,JArray []])
--
-- >>> parse jsonContainer "{ \"key1\" : true , \"key2\" : false } xyz"
-- Just ("xyz",JObject [("key1",JTrue),("key2",JFalse)])
jsonContainer :: Parser JsonValue
-- What: read an array or an object.
-- How:  try jsonArray. If the input does not start with '[', try jsonObject.
--   BNF: <JSONContainer> ::= <Array> | <Object>
jsonContainer = jsonArray <|> jsonObject

-- | Parse a JSON string.
--
-- /Hint/: Use the parsers we have just made for each component of the JSON
--  type.
--
--
-- >>> parse json "true"
-- Just ("",JTrue)
--
-- >>> parse json "{ \"key1\" : true , \"key2\" : [7, false] }"
-- Just ("",JObject [("key1",JTrue),("key2",JArray [JInteger 7,JFalse])])
--
-- >>> parse json "{ \"key1\" : true , \"key2\" : [7, false] , \"key3\" : { \"key4\" : null } }"
-- Just ("",JObject [("key1",JTrue),("key2",JArray [JInteger 7,JFalse]),("key3",JObject [("key4",JNull)])])
json :: Parser JsonValue
-- What: read any JSON value. This is the entry point of the parser.
-- How:  try a simple value. If that fails, try a container.
--   BNF: <JSON> ::= <JSONVal> | <JSONContainer>
--   jsonArray and jsonObject call json again for their items. This is how
--   nested JSON works (see the notes on jsonArray about infinite loops).
json = jsonVal <|> jsonContainer
