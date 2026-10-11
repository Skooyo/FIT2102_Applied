# MiniZinc Answers

Solver: Gecode (MiniZinc 2.10.1).

## Step 1

```minizinc
var 1..10: x;
constraint x > 5;
solve satisfy;
```

Output:

```
x = 6;
----------
```

## Step 2

Before the extra constraint:

```minizinc
var 1..10: x;
var 1..10: y;

constraint x + y = 10;

solve satisfy;
```

```
x = 9;
y = 1;
----------
```

After adding `y > x`:

```minizinc
var 1..10: x;
var 1..10: y;

constraint x + y = 10;
constraint y > x;

solve satisfy;
```

```
x = 4;
y = 6;
----------
```

## Step 3

```minizinc
int: n = 10;
var 1..n: x;

var 1..10: y;

constraint x + y = 10;

solve satisfy;
```

```
x = 9;
y = 1;
----------
```

After adding `x > y`:

```minizinc
int: n = 10;
var 1..n: x;

var 1..10: y;

constraint x + y = 10;
constraint x > y;

solve satisfy;
```

```
x = 9;
y = 1;
----------
```

The first solution already has `x > y`, so the result does not change.

## Step 4

```minizinc
int: n = 5;
array[1..n] of var 1..n: a;

constraint forall(i in 1..n)(a[i] >= i);
solve satisfy;
```

```
a = [1, 2, 3, 4, 5];
----------
```

## Step 5

```minizinc
include "alldifferent.mzn";

int: n = 5;
array[1..n] of var 1..n: a;

constraint alldifferent(a);

solve satisfy;
```

```
a = [5, 4, 3, 2, 1];
----------
```

## Step 6

`maximize total`:

```minizinc
include "alldifferent.mzn";

int: n = 5;

array[1..n] of var 1..n: a;

constraint alldifferent(a);
var int: total = sum(a) * (a[n] - a[1]);

solve maximize total;
```

```
a = [1, 4, 3, 2, 5];
_objective = 60;
----------
==========
```

`minimize total` (same model, last line changed to `solve minimize total;`):

```
a = [5, 4, 3, 2, 1];
_objective = -60;
----------
==========
```

`sum(a)` is always 15 because `a` is a permutation of 1..5. So the objective only depends on `a[n] - a[1]`: max is 15 * 4 = 60, min is 15 * -4 = -60. `==========` means the solver proved the solution is optimal.

## Step 7

```minizinc
include "alldifferent.mzn";

int: n = 8;
array[1..n] of var 1..n: row;

constraint alldifferent(row);
constraint alldifferent([row[i] + i | i in 1..n]);
constraint alldifferent([row[i] - i | i in 1..n]);

solve satisfy;
```

```
row = [4, 2, 7, 3, 6, 8, 5, 1];
----------
```

Gecode returns this solution almost instantly.
