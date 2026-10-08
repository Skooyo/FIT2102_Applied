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
