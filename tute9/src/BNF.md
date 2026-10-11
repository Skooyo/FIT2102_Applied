Your job is to write the `<Array>` and `<Object>` sections of the following BNF. It should look something like the non-terminal `<String>`.

```BNF
<JSON> ::= <JSONVal> | <JSONContainer>
<JSONVal> ::= <Integer> | <Null> | <Bool> | <String>
<JSONContainer> ::= <Array> | <Object>
<Integer> ::= <Digit> | <Digit> <Integer>
<Digit> ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
<Null> ::= "null"
<Bool> ::= <True> | <False>
<True> ::= "true"
<False> ::= "false"
<String> ::= '"' <StringContents> '"' | '"' '"'
<StringContents> ::= <Char> | <Char> <StringContents>
<Char> ::= 'a' | 'b' | 'c' | ...
<Array> ::= '[' <ArrayContents> ']' | '[' ']'
<ArrayContents> ::= <JSON> | <JSON> ',' <ArrayContents>
<Object> ::= '{' <ObjectContents> '}' | '{' '}'
<ObjectContents> ::= <Pair> | <Pair> ',' <ObjectContents>
<Pair> ::= <String> ':' <JSON>
```

## Notes on the new rules

### How to read BNF

- `::=` means "is defined as".
- `|` means "or".
- Text in quotes is a literal character or string.
- `<Name>` is a non-terminal, which is another rule.

### `<Array>`

- An array is `[`, then its contents, then `]`.
- The second option, `'[' ']'`, is the empty array `[]`.
- This uses the same pattern as `<String>`: `'"' <StringContents> '"' | '"' '"'`.

### `<ArrayContents>`

- One `<JSON>` value, or one value followed by `,` and more contents.
- Plain BNF has no `*` (repeat) operator, so a list must use recursion. `<StringContents>` repeats `<Char>` in the same way.
- The comma is only *between* items, so `[1,]` and `[,1]` are not valid.
- Each item is `<JSON>`, not `<JSONVal>`. So arrays can contain arrays and objects: `[1, [2], {"a": null}]`.

### `<Object>` and `<ObjectContents>`

- The same pattern as `<Array>` and `<ArrayContents>`, with `{` `}` and `<Pair>` items.
- `{}` is the empty object.

### `<Pair>`

- A key and a value, for example `"name": "bob"`.
- The key is a `<String>`, because JSON keys are always strings.
- The value is `<JSON>`, so values can be nested.
- This rule is optional. It only gives a name to `<String> ':' <JSON>`. The inline version accepts the same input:
  `<ObjectContents> ::= <String> ':' <JSON> | <String> ':' <JSON> ',' <ObjectContents>`

### Why the recursion does not loop

`<JSON>` uses `<Array>`, and `<Array>` uses `<JSON>`. This is not a loop, because each path must first match `[` or `{`. Each nested level uses some input. Thus the nesting stops when the input ends.

### Whitespace

The grammar does not show whitespace, because the given rules also leave it out. In `JSON.hs`, `tok` removes the spaces after each token.

### How each rule maps to `JSON.hs`

| BNF rule | Haskell parser |
|---|---|
| `<JSON>` | `json = jsonVal <\|> jsonContainer` |
| `<JSONVal>` | `jsonVal = asum [jsonInteger, jsonString, jsonBool, jsonNull]` |
| `<JSONContainer>` | `jsonContainer = jsonArray <\|> jsonObject` |
| `<Array>` + `<ArrayContents>` | `isTok '[' *> sepBy json commaTok <* isTok ']'` |
| `<Object>` + `<ObjectContents>` | `isTok '{' *> sepBy kv commaTok <* isTok '}'` |
| `<Pair>` | `kv = (,) <$> tok quoteString <* isTok ':' <*> json` |
| `<String>` | `quoteString = is '"' *> many (isNot '"') <* is '"'` |

- `|` in BNF becomes `<|>` in Haskell.
- "Contents or empty" (`'[' <ArrayContents> ']' | '[' ']'`) becomes `sepBy`, because `sepBy` accepts zero items.

### Example derivation: `{"a": [1, 2]}`

1. `<Object>` → `'{' <ObjectContents> '}'`
2. `<ObjectContents>` → `<Pair>` → `<String> ':' <JSON>`
3. `<String>` → `"a"`
4. `<JSON>` → `<JSONContainer>` → `<Array>` → `'[' <ArrayContents> ']'`
5. `<ArrayContents>` → `<JSON> ',' <ArrayContents>` → `1 , 2`
