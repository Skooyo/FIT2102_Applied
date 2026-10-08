# MiniZinc Tutorial: From Variables to N-Queens

MiniZinc is a constraint modelling language: you describe *what* a valid solution looks like, and a solver figures out *how* to find one. This tutorial builds up from the basics to a full N-Queens model.

You will be using the [online playground](https://play.minizinc.dev/), which will include the solver and a simple dev environment.

For the following tutorial, create a Markdown file. For each task, include the MiniZinc code you used and the corresponding output. Use **Gecode** as the solver

---

## Step 1: Your first model - a single variable

Every MiniZinc program declares variables and constraints, then asks the solver to find values.

For example,

```minizinc
var 1..10: x;
constraint x > 5;
solve satisfy;
```

- `var 1..10: x;` declares a **decision variable** `x` whose domain is the integers 1 through 10.
- `constraint x > 5;` restricts allowed values.
- `solve satisfy;` tells the solver "find any value that satisfies the constraints."

### Task
Run it and report what the solver says.

---

## Step 2: Multiple variables and arithmetic constraints

```minizinc
var 1..10: x;
var 1..10: y;

constraint x + y = 10;

solve satisfy;
```

Multiple `constraint` statements are combined with AND; all must hold simultaneously.


### Task
Add another constraint, that `y` must be larger than `x`, and report values before and after this extra constraint.

---

## Step 3: Parameters vs. variables

```minizinc
int: ???
var ???

var 1..10: y;

constraint x + y = 10;

solve satisfy;
```

MiniZinc separates **parameters** (fixed data, known before solving) from **decision variables** (unknowns that the solver assigns).

`int: n = 8;` is a plain constant. `var 1..n: x;` uses it to size the domain. This separation matters a lot: parameters let you write one model that works for many inputs (e.g., N-Queens for any N) without touching the constraints.

### Task
Complete the model above with the constant and `var`, run it and note the solved values. Then, add a second constraint that `x` must be larger than `y` and report values after this extra constraint.

---

## Step 4: Arrays of variables

Real problems usually need many related variables. An array is a natural fit.

```minizinc
int: n = 5;
array[1..n] of var 1..n: a;

constraint forall(i in 1..n)(a[i] >= i);
solve satisfy;
```

- `array[1..n] of var 1..n: a;` declares `n` decision variables, each with domain `1..n`, indexed `a[1]..a[n]`.
- `forall(i in 1..n)(...)` is a **comprehension**: it generates one constraint per `i` and ANDs them together. This is how we can express "for every element/pair/row..." constraints.


### Task
Run the model, inspect and report the array of values returned.

---

## Step 5: `alldifferent` - your first global constraint

Many classic puzzles boil down to "these values must all be distinct." MiniZinc's standard library has a built-in for this.

```minizinc
include "alldifferent.mzn";

int: n = 5;
array[1..n] of var 1..n: a;

solve satisfy;
```

- `include "alldifferent.mzn";` imports the global constraint library.
- `alldifferent(a)` is both clearer to read *and* usually solves faster than the equivalent hand-written pairwise inequalities, because solvers implement specialised propagation for it.

### Task

Add a constraint `alldifferent(a)` to the above program. Report the updated code and the values returned by the solver.

---

## Step 6: Optimisation instead of satisfaction

So far we've only asked "find *a* solution." You can also ask for the *best* one.

```minizinc
include "alldifferent.mzn";

int: n = 5;

array[1..n] of var 1..n: a;

constraint alldifferent(a);
var int: total = sum(a) * (a[n] - a[1]);

solve maximize total;
```

- `solve maximize total;` (or `minimize`) searches for the best objective value.
- `sum(a)` and similar aggregate functions (`min`, `max`, `count`) work over arrays and comprehensions. 
- `sum(a) * (a[n] - a[1])` multiplies the sum of the elements by the last element minus the first.

For `maximize` and `minimize` directives, the solver outputs each solution that improves the objective as it goes, so the last solution it outputs is the best one.

This isn't needed for N-Queens itself, but it becomes essential once you move on to scheduling, packing, or optimisation problems.

### Task
Run the model with `maximize total`, then change it to `minimize total` and run it again. Report the values returned by the solver for both directives.

---

## Step 7: N-Queens - the board representation

The classic approach is to represent the board with **one variable per column**, whose value is the row of the queen in that column. This automatically guarantees exactly one queen per column, and you only need three more constraint types:

1. No two queens share a row `alldifferent(row)`
2. No two queens share a "/" diagonal
3. No two queens share a "\\" diagonal

The diagonal trick works because two queens `(i, row[i])` and `(j, row[j])` share a diagonal exactly when `row[i] + i = row[j] + j` or `row[i] - i = row[j] - j`. Making each of those expressions `alldifferent` across columns rules that out.

```minizinc
include "alldifferent.mzn";

int: n = 8;
array[1..n] of var 1..n: row;

constraint alldifferent(row);
constraint alldifferent([row[i] + i | i in 1..n]);
constraint ???;

solve satisfy;
```

- `[row[i] + i | i in 1..n]` is an **array comprehension**: build a new array by evaluating an expression for each `i`. It has the same `| generator` syntax as `forall`, but it produces values instead of constraints.


### Task
Add the third missing constraint, then run this with `n = 8` and confirm Gecode returns a valid arrangement almost instantly. Report the values returned by the solver.
