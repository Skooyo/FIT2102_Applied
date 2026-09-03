1. I-Combinator in Javascript
The I-Combinator is a function that returns its argument without changing anything (just returns the input back). It can be used when you need a function that does nothing, such as a default callback, or an unchanged transformation. However, it can also be used as a building block in combinatory logic and functional programming.

In lambda calculus, its equivalence is λx.x

The I-Combinator, or identity function returns its argument unchanged. It is useful when used as a default transformation, callback, or building block in combinatory logic and functional programming.

Its equivalence in lambda calculus is λx.x

2. Alpha equivalence
2.1 Which lambda expression is alpha equivalent to λx.x:
For an input x, return x
λa.a
This is basically the same, for an input a, return a

2.2 Which lambda expression is alpha equivalent to λxy.yx:
This can be reconstructed to λx. (λy . (yx))
Which means take two inputs, x and y, and then return yx
λa.(λb.ba)
This equivalence just changes the letters x -> a and y -> b, and accomplishes
the same thing

2.3 Which lambda expression is alpha equivalent to λxy.xz:
This can be reconstructed to λx. (λy . (xz))
We can see that x is bound and y is bound, while z is free since no lambda introduces z
λmn.mz
This lambda equation is the same as x -> m and y -> n, but the free z must stay as z.

3. Applying beta reduction to lambda functions
3.1 (λx.x)y
Apply λx.x to the input y,
Therefore (λx.x)y = y

3.2 λx.xx
We cannot reduce this as λx.xx has no input after it, it is only a function definition
So, λx.xx is already in normal form.

If we were to give it an input and apply it to itself, we have
(λx.xx)(λx.xx)

If we replace both occurence of x in xx with the input (λx.xx), we get
(λx.xx)(λx.xx), which is the exact same expression.
If we reduce it again, the same output will be produced,
so it never reaches an answer, meaning it diverges.

3.3 (λz.zz)(λy.yy)
Replace both occurences of z in zz with the input, (λy.yy)
we get (λy.yy)(λy.yy). Now, we have the same kind of fnuction applied
to itself, if we replace both occurences of y in yy with the input (λy.yy), we get
(λy.yy)(λy.yy)

Once again, the expression produces itself, meaning this repeats forever, so it never
reaches a normal form and it diverges.

3.4 (λx.xx)y
Replace both occurences of x in xx with the input, y
We get yy. There is no more reduction since y is just a variable, not a lambda function
So, the normal form is yy.

4. Beta reduce the following expressions
4.1 (λy.zy)a
replace y with the input a,
we get za
No more lambda function, so za is the normal form

4.2 (λx.x)(λx.x)
Replace the x in the first function with the input, (λx.x)
we get λx.x

No input is given, so λx.x is the normal form

4.3 (λx.xy)(λx.xx)
Replace the first x with the input, (λx.xx)
we get (λx.xx)y

We can apply the function again, replacing both x in xx with y
we get yy
The normal form is yy since we no longer have any lambda functions

4.4 (λz.z)(λa.aa)(λz.zb)
Replace z with the first input, (λa.aa)

We get (λa.aa)(λz.zb)
Replace both a in aa with the second input, (λz.zb)
(λz.zb)(λz.zb)

Replace z in zb with the third input, (λz.zb)
(λz.zb)b

Replace z in zb with b,
bb

no more lambda functions are present, bb is the normal form

5. Eta conversion
Given a lambda function λx.(f x), we can simply take the function f by doing an eta reduction.

5.1 λx.zx
λx.zx follows the pattern of λx.(f x), so we can reduce
λx.zx -> z

5.2 λx.xz
We cannot eta reduce this function as x is being used as the function

5.3 (λx.bx)(λy.ay)
Eta reduce (λx.bx) -> b
Eta reduce (λy.ay) -> a

so we get ba after it is reduced

6. Which of the following are combinators
6.1 λx.xxx
This function is a combinator as all x's are bounded by λx

6.2 λxy.zx
This function is not a combinator as x and y are bounded but z isnt

6.3 λxyz.xy(zx)
This function is a combinator because all variables x, y, and z are all bounded

6.4 λxyz.xy(zxy)
This function is a combinator becuase all variables x, y, and z are all bounded

7. Apply g to y-combinator
Y=λf.(λx.f(xx))(λx.f(xx))

Apply g to it, so
λf.(λx.f(xx))(λx.f(xx))g

Replace f with g,
(λx.g(xx))(λx.g(xx))

replace x with (λx.g(xx))
g((λx.g(xx))(λx.g(xx)))

(λx.g(xx))(λx.g(xx)) is Y applied with g, so we can substitute this to
g(Y g)

If we continue reducing this, we will get
Y g -> g(Y g) -> g(g(Y g)) -> ...

So, we cant simplify it further without actually knowing what g is.

8. Church Encoding
Using: 
`TRUE = \xy. x`
`FALSE = \xy. y`
`IF = \btf. b t f`
`AND = \xy. IF x y FALSE`
`OR = \xy. IF x TRUE y`
`NOT = \x. IF x FALSE TRUE`

8.1 Evaluate NOT FALSE

NOT = λx.IF x FALSE TRUE

Apply it to FALSE, so
(λx.IF x FALSE TRUE) FALSE
replace x with FALSE,
we get IF FALSE FALSE TRUE

Use IF = \btf. b t f
(λbtf. b t f) FALSE FALSE TRUE
we get FALSE FALSE TRUE

Use FALSE = λxy. y, apply FALSE TRUE
(λxy. y) FALSE TRUE
we get TRUE,

So, NOT FALSE = TRUE

8.2 Evaluate OR TRUE FALSE

OR = λxy. IF x TRUE y

(λxy. IF x TRUE y) TRUE FALSE

Replace x with TRUE and y with FALSE

IF TRUE TRUE FALSE
IF = \btf. b t f

(λbtf. b t f) TRUE TRUE FALSE

TRUE TRUE FALSE
TRUE = λxy. x
(λxy. x) TRUE FALSE
TRUE

Therefore, OR TRUE FALSE = TRUE

8.3 Evaluate AND TRUE TRUE
Use `AND = \xy. IF x y FALSE`

(λx.λy.IF x y FALSE) TRUE TRUE, replace x with TRUE and y with TRUE
IF TRUE TRUE FALSE

IF = \btf. b t f
(λbtf. b t f) TRUE TRUE FALSE, replace b with TRUE, t with TRUE, f with FALSE
TRUE TRUE FALSE

Use TRUE = λxy. x
(λxy. x) TRUE FALSE, replace x with TRUE
TRUE

9. Translate the following lambda expressions into JavaScript arrow functions.
9.1 λxy.x
x => y => x

9.2 λfx.f(f x)
f => x => f(f(x))

9.3 λf.λg.λx.f(g x)
f => g => x => f(g(x))