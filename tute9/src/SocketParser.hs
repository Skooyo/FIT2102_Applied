module SocketParser (parseURL, getOrPost, parseHTTPRequest) where

import Control.Applicative (many, (<|>))
import Instances (Parser (..))
import JSON
    ( JsonValue (JNull)
    , json
    , stringTok
    , tok
    )
import Parser (isNot, string)

-- $setup
-- >>> import Instances (parse)

-- | Parse a URL-like string until a space is encountered
--
-- This parser consumes characters until it finds a space.
-- It's useful for parsing the URL portion of an HTTP request, assuming spaces are not allowed in the URL.
-- Hint: What does alternative give us
--
-- >>> parse parseURL "http://example.com/homepage GET"
-- Just (" GET","http://example.com/homepage")
-- >>> parse parseURL "my-url POST"
-- Just (" POST","my-url")
-- >>> parse parseURL "invalid_url"
-- Just ("","invalid_url")
parseURL :: Parser String
-- What: read all characters up to the first space (or the end of the input).
-- How:  isNot ' ' matches one character that is not a space.
--   many runs it again and again until it fails, and collects the characters.
--   It fails at a space or at the end of the input. Then many stops and
--   returns what it has. The space stays in the rest.
--   many comes from Alternative (many p = some p <|> pure []). That is the
--   answer to the hint "what does alternative give us".
parseURL = many (isNot ' ')

-- | Parse either "GET" or "POST"
--
-- This parser checks if the input starts with "GET" or "POST".
-- It succeeds if either one is matched, returning the rest of the input along with the matched string.
--
-- >>> parse getOrPost "GET /index.html"
-- Just (" /index.html","GET")
-- >>> parse getOrPost "POST /submit-form"
-- Just (" /submit-form","POST")
-- >>> parse getOrPost "PUT /update"
-- Nothing
-- >>> parse getOrPost "post /lowercase"
-- Nothing
getOrPost :: Parser String
-- What: match the HTTP method "GET" or "POST".
-- How:  try string "GET". If it fails, <|> tries string "POST" on the SAME
--   input (the failed attempt does not use any input).
--   "PUT" fails both. "post" fails both, because string is case-sensitive.
getOrPost = string "GET" <|> string "POST"

-- | Parse an HTTP request, with optional arguments as JSON.
-- Consuming any trailing whitespace
--
-- >>> parse parseHTTPRequest "POST /submit-form HTTP/1.1 {\"key1\": true, \"key2\": [1, 2, 3]}   "
-- Just ("",("POST","/submit-form",JObject [("key1",JTrue),("key2",JArray [JInteger 1,JInteger 2,JInteger 3])]))
-- >>> parse parseHTTPRequest "POST /submit-form HTTP/1.1 {\"key1\": null}"
-- Just ("",("POST","/submit-form",JObject [("key1",JNull)]))
-- >>> parse parseHTTPRequest "GET /index.html HTTP/1.1"
-- Just ("",("GET","/index.html",JNull))
parseHTTPRequest :: Parser (String, String, JsonValue)
-- What: read "METHOD URL HTTP/1.1 [JSON]" and return (method, url, body).
-- How:  (,,) is the 3-tuple constructor: (,,) a b c = (a, b, c).
--   The parts run one after the other:
--     1. tok getOrPost          the method, then its spaces     -> a
--     2. tok parseURL           the URL, then its spaces        -> b
--     3. stringTok "HTTP/1.1"   the version; <* DROPS its result
--     4. json <|> pure JNull    the body (optional)             -> c
--   Trailing whitespace: json removes the spaces after itself (tok), so the
--   "   " at the end of the first example is used up.
--
-- How <|> handles POST (with JSON) and GET (no JSON):
--   After step 3, the rest of the input is:
--     POST: "{\"key1\": null}"  -> json succeeds, so <|> returns its result.
--     GET:  ""                  -> json fails (there is nothing to read).
--   When the left side of <|> fails, <|> runs the right side on the SAME
--   input. pure JNull always succeeds, uses no input, and returns JNull.
--   So the body is optional: one parser covers both cases, and there is no
--   "if method == GET" check. The result type stays (String, String, JsonValue)
--   in both cases, with JNull as the "no body" value.
--
--   This works because our <|> (see Instances.hs) gives the ORIGINAL input to
--   the second parser. The failed json attempt does not use any input.
--
--   Limit: if a POST body has bad JSON, json fails and pure JNull succeeds.
--   The bad text stays in the rest of the input, so the caller can see it.
parseHTTPRequest =
    (,,)
        <$> tok getOrPost
        <*> tok parseURL
        <* stringTok "HTTP/1.1"
        <*> (json <|> pure JNull)
