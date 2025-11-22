# Reasoning
## Principles
**Referential Transparency** - We can always replace an expression in any context by one that is known to be equal to it.
**Induction** - For any recursive data type, we prove the property true for the non-recursive variants, and then for every recursive (composite) variant, we assume the property is true for the recursive variants, and from this show it still holds for the composite.
**Case-splitting** - Conditionals (and Patterns) are handled by case analysis - condition true/false, all possible matches.

## Simple Proof Example
Lets prove `length (1:2:3:[]) == 3`
To do this we will need the definition of `length`, plus some laws about equality.
```haskell
length [] = 0                 -- length.1
length (_:xs) = 1 + length xs -- length.2
x == x = True                 -- ==-refl
x == y = y == x               -- ==-comm
x == y && y == z ==> x == z   -- ==-trans
```
Each definition clause, and law, gets a "name".
We also need a proof strategy.

### Strategy
The simplest strategy is to "Reduce to True" using laws/definitions to transform the initial predicate to True.
Each step is justified by appealing to a law or definition.
We are relying on referential transparency here, and matching. Given law `lhs == rhs`, we have 3 options:
1. Match whole law against some sub-expression, and replace that by True
2. Match lhs against some sub-expression, and replace that by rhs.
3. Match rhs against some sub-expression, and replace that by lhs.

### Proof
``` haskell
length (1:2:3:[]) == 3
= ”length.2, left2right, at 1st occurrence of length”

1 + length (2:3:[]) == 3
= ”length.2, left2right, at 1st occurrence of length”

1 + (1 + length (3:[])) == 3
= ”length.2, left2right, at 1st occurrence of length”

1 + (1 + (1 + length [])) == 3
= ”length.1, left2right, at 1st occurrence of length”

1 + (1 + (1 + 0)) == 3
= ”simplify”

3 == 3
= ”==-refl, at top-level”

True
```

We could also write our proof like this:
```haskell
length (1:2:3:[])
= ”length.2, left2right, at 1st occurrence of length”

1 + length (2:3:[])
= ”length.2, left2right, at 1st occurrence of length”

1 + (1 + length (3:[]))
= ”length.2, left2right, at 1st occurrence of length”

1 + (1 + (1 + length []))
= ”length.1, left2right, at 1st occurrence of length”

1 + (1 + (1 + 0))
= ”simplify”

3
```

# Proof Checking
Formal proofs are hard to find, but they are easy to check automatically.
We need a machine-readable notation for writing proofs, with:
- a precise syntax
- a precise semantics
Such a tool exists for this module (CSU34016): `prfchk`

## Proof Checking Syntax (Top Level)
We keep theories in files with extension: `.thr`
Typically a keyword (all UPPERCASE) at the start of a line introduces something.
We start with THEORY and zero or more imports:
```
THEORY <TheoryName>
IMPORT-THEORY <FileName>
IMPORT-HASKELL <FileName>
```
These are followed by zero or more entries that describe:
- laws
- induction schemes
- case-based approaches
- theorems to be proven
## Proof Checking Syntax (Laws)
Laws are described by the following one-liner construct:
```
LAW <name> <br?> <expr>
```
- The name should be unique
- The expr part is a Haskell expression of type Bool.
- Here, <br?> means that the following expr is either entirely on this line, or else occupies a number of subsequent lines.
- If it occupies subsequent lines then there can be a blank line before it, but there must also be a blank line after it.
- It must not have blank lines embedded in it.
### Laws Example
The following are all valid ways to write a given law.
```
LAW add_sym x + y == y + x
LAW add_sym

x + y == y + x

LAW add_sym
x + y
==
y + x

```
## Proof Checking Syntax (Theorems)
A theorem has the following top level structure:
```
THEOREM <name> <br?> <expr>
STRATEGY <strategy-type>
<strategy-body>
QED <name>
```

The name used with THEOREM and QED should be the same.
Strategy types include:
`<strategy-type> = ReduceAll | ReduceLHS | ReduceRHS | ReduceBoth | ...`

## Proof Checking Syntax (Strategy-Bodies)
If the strategy chosen is ReduceAll, ReduceLHS, or ReduceRHS, then the strategy-body is simply a calculation.
If the strategy chosen is ReduceBoth, then the strategy-body is:
```
LHS
<calculation>
RHS
<calculation>
```
There are other more complex strategies, which ultimately end up using one or more of these reduce strategies.

## Proof Checking Syntax (Calculation)
A calculation is a sequence of expressions separated by justification lines, which always start with an equal sign.
Blank lines are allowed around justification lines.
```
<expr1>
= <justification1>
...
= <justificationN>
<exprN+1>
```

## Proof Checking Syntax (Justification Laws)
The justification format is as follows:
```
law [usage] [focus]
```
We need to provide a law for every justification. Some possibilities are:

| syntax     | meaning                                |
| ---------- | -------------------------------------- |
| LAW name   | name of law                            |
| DEF name   | definition of name                     |
| DEF name.i | definition of name, identifying clause |
| SIMP       | builtin simplifier                     |
LAW, DEF and SIMP are keywords. There are others.
DEF: what's in a name?
- The DEF keyword is used for laws resulting from Haskell function definitions.
- The name is the Haskell name of the function.
- If the function is defined using N patterns, then name.i refers to the ith pattern, numbered from 1 upwards.
- e.g. DEF length.1
## Proof Checking Syntax (Justification Syntax)
The usage component only applies for laws of the form lhs = rhs, of DEFs, and is optional in those cases.

| syntax | meaning       |
| ------ | ------------- |
| l2r    | left-to-right |
| r2l    | right-to-left |
For a LAW, if the usage is omitted, the whole law is matched.
For a DEF, if omitted, it defaults to l2r.
l2r and r2l are keywords.

## Proof Checking Syntax (Justification Focus)
The focus component is optional.

| syntax   | meaning                               |
| -------- | ------------------------------------- |
| @ name   | The first occurrence of that name     |
| @ name i | ith in-order occurrence of that name. |
For a DEF, if focus is omitted is defaults to @ name 1.
Otherwise, if omitted, the focus is at the top level.
Another keyword is @.
### What is an "occurrence of a name"
We are referring to a name in the current expression.
The name will refer to some variable/or function definition.
If a simple variable definition (v = 42) then v i refers to the ith occurrence of v in the expression, scanning from left-to-right.
If a function definition (f x y = ...) the f i refers to the ith occurrence of f as above, but, the focus is on the application of that function to its arguments.
So, for example, given: `length (x:xs) ++ length (y:ys) ++ zs` the focus @ length 2 is `length(y:ys)`

# Demos
## Induction
### Proof Example (Property)
Example: lets prove `length (xs + ys) = length xs + length ys`
Lists are defined inductively as either `[]` or `x:xs`, where xs is a pre-existing list.
We do an inductive proof, on xs
P(xs) b= length (xs++ys) = length xs + length ys

### Proof Example (Base Case)
``` haskell
P([])
= ”expand P”
length ([]++ys) = length [] + length ys
= ”Defs of ++ and length”
length ys = 0 + length ys
= ”arithmetic”
length ys = length ys
= ”reflexivity of =”
True
```
Easy ! Note how each line of the proof has a justification (in double quotes)
### Proof Example (Inductive Step)
Assume P(xs), i.e. length (xs++ys) = length xs + length ys
Show P(x:xs):
```haskell
P(x:xs)
= ”expand P”
length ((x:xs)++ys) = length (x:xs) + length ys
= ”Defs of ++ and length”
length (x:(xs++ys)) = (1 + length xs) + length ys
= ”Defs of length, + is assoc”
1 + length (xs++ys) = 1 + (length xs + length ys)
= ”arithmetic”
length (xs++ys) = length xs + length ys
= ”by ind. hypothesis”
True
```

## Checking Induction
We can use `prfchk` to check induction proofs.
For an inductive proof we need two things:
1. an induction schema
2. a strategy that says we are doing induction with such a schema
### ProofCheck Induction Schema for Naturals
P (0) ∧ (P (x) ⇒ P (x + 1)) proves inductively that P (n) holds for all n ∈ N
In a prfchk theory file we can specify this as follows:
```
INDUCTION-SCHEME Nat
BASE 0
STEP x --> x + 1
INJ ( x == y ) == ( (x + 1) == (y + 1) )
```
The last line above is usually taken for granted, but needs to be explicitly stated for a theorem prover or checker.

### ProofCheck Induction Schema for Lists
P ([]) ∧ (P (xs) =⇒ P (x : xs)) proves inductively that P (ys) holds for all ys ∈ [t]
In a prfchk theory file we can specify this as follows:
```
INDUCTION-SCHEME List
BASE []
STEP xs --> (x:xs)
INJ ((x == y)&&(xs == ys)) == ((x:xs) == (y:ys))
```

### Checking Induction Proof
There is an induction strategy that can be used for proofs:
```
STRATEGY Induction <ind-var> :: <type>
BASE <val> <br!> <expr>
<strategy for base case proof>
QED BASE
STEP <expr>
ASSUME <br?> <expr>
SHOW <br?> <expr>
<strategy for inductive case proof>
QED STEP
```

### Checking Induction Proof for Lists
Using the induction strategy for lists
```
STRATEGY Induction xs :: List
BASE [] <br!> P([])
<strategy for base case proof>
QED BASE
STEP (x:xs)
ASSUME <br?> P(xs)
SHOW <br?> P(x:xs)
<strategy for inductive case proof>
QED STEP
```

# Demo
## Reasoning by Cases
Set as unique ordered list.
Consider using an ordered list with no duplicate elements to represent a set.
Insertion:
```haskell
ins :: Ord t => t -> [t] -> [t]
ins x [] = [x]
ins x ys@(y:zs)
| x < y = x : ys -- smallest at start
| x > y = y : ins x zs -- recurse in
| otherwise = ys -- already present
```

Membership test:
```haskell
mbr :: Ord t => t -> [t] -> Bool
mbr _ [] = False
mbr x (y:ys)
| x < y = False
| x > y = mbr x ys
| otherwise = True
```

#### Insertion Implies Membership
We want to prove that, after we do `ins x ys`, the test `mbr x ys` always returns True
`mbr x (ins x ys) = True`
We do an induction on ys:
P(ys) b= mbr x (ins x ys)
So we have to show:
P([])
P(ys) ==> P(y:ys)

#### Proof, Base Case
```haskell
P([])
= ”defn of P”
mbr x (ins x [])
= ”defn. of ins, 1st pattern”
mbr x [x]
= ”defn. of mbr, 2nd pattern, otherwise case”
True
```

#### Proof, Inductive Step
```haskell
P(ys) ==> P(y:ys)
= ”defn of P”
mbr x (ins x ys) ==> mbr x (ins x (y:ys))
```
We shall assume the lhs (induction hypothesis) and attempt to show the rhs is true.
It’s worth trying this to see how tricky it gets.
We have another proof trick that can help.
#### Proof by Cases
It can be simpler sometimes to split a proof into cases
With conditionals in programs, it is often the only way to progress the proof.
The simplest is to split based on a predicate: To prove P we choose an appropriate splitting predicate S, and we then prove that S ⇒ P and ¬S ⇒ P .
Sometimes we want a multiway case-split: C1, C2, . . . , Cn and we then prove that Ci ⇒ P for i ∈ 1 . . . n.
For a multiway case-split, the Ci must be:
- Exhaustive (C1 ∨ C2 ∨ · · · ∨ Cn = True)
- Disjoint (Ci ∧ Cj = False, for all i, j)
- The number of Ci ∧ Cj pairs to be tested is given by n(n+1)/2
#### Proof, Inductive Step
We shall assume the hypothesis mbr x (ins x ys) and plan to show that
mbr x (ins x (y:ys)) is true.
We shall use an obvious case split (look at the code!!)
We split on the relationship between x and y : x<y, x>y and x == y
We can prove that these are exclusive and exhaustive.
#### Proof, Inductive Step, x < y
We assume: mbr x (ins x ys) and x<y.
```haskell
mbr x (ins x (y:ys))
= ”defn. ins, 2nd pattern, x<y”
mbr x (x:y:ys)
= ”defn. mbr, 2nd pattern otherwise case”
True
```

#### Proof, Inductive Step, x > y
We assume: mbr x (ins x ys) and x>y.
```haskell
mbr x (ins x (y:ys))
= ”defn. ins, 2nd pattern given x>y”
mbr x (y: ins x ys)
= ”defn. mbr, 2nd pattern, x > y case”
mbr x (ins x ys)
= ”inductive hypothesis”
True
```

#### Proof, Inductive Step, x == y
We assume: mbr x (ins x ys) and x == y.
```haskell
mbr x (ins x (y:ys))
= ”defn. ins, 2nd pattern, x==y”
mbr x (y:ys)
= ”defn. mbr, 2nd pattern, otherwise case”
True
```

## Proof-Checking
### Checking Proof by Cases
We can use the induction strategy for lists:
```
STRATEGY CaseSplit <case-name>
CASE 1 <br!> <expr>
SHOW <br!> <expr>
<strategy>
END CASE 1
...
CASE N <br!> <expr>
SHOW <br!> <expr>
<strategy>
END CASE N
END CaseSplit
```

### Checking Proof with Conditionals/Patterns
All our proofs so far only involve functions with patterns, what about conditionals?
```haskell
fac n = if n == 0 then 1 else n * fac (n-1)
ins x [] = [x]
ins x (y:ys)
| x < y = x:y:ys
| x == y = y:ys
| x > y = y : ins x ys
```
We can handle the fac example quite nicely.
#### Law type: IF
Given an if-then-else expression, where the condition has been evaluated to True
or False we have two possibilities:

if True then expr1 else expr2
= IF 1
expr1

if False then expr3 else expr4
= IF 2
expr4

You identify which branch (1 or 2) will be the result.

What about pattern guards?
```haskell
ins x [] = [x]
ins x (y:ys)
| x < y = x:y:ys
| x == y = y:ys
| x > y = y : ins x ys
```

The problem with ins is: We can easily identify the LHS (ins x []) and
the RHS ([x]) for the first ins clause But the RHS for the 2nd clause is not
obvious!

```haskell
| x < y = x:y:ys
| x == y = y:ys
| x > y = y : ins x ys
```

Not a valid Haskell expression!

#### Haskell CORE syntax
Haskell gets transformed into a simpler CORE syntax.
A definition of a function f x y z = ..., no matter how written, is converted into a lambda definition x y z -> ...
Top-level pattern matching gets converted into case expressions.
prfchk requires us to use this form.
#### Functions in CORE
Function Definition:
```haskell
f p1 | g11 = e11
...
| g1m = e1m
...
f pK | gK1 = eK1
...
| gKn = eKn
```
becomes the following CORE syntax
```haskell
f e = case e of
p1 | g11 -> e11
...
| g1m -> e1m
...
pK | gK1 -> eK1
...
| gKn -> eKn
```

#### Example
```haskell
ins x [] = [x]
ins x (y:ys)
| x < y = x:y:ys
| x > y = y : ins x ys
| x == y = y:ys
```

Turns in to:
```haskell'
ins x zs = case zs of
[] -> [x]
(y:ys) | x < y -> x:y:ys
| x > y -> y : ins x ys
| x == y -> y:ys
```

#### We can split this up
In this case, as the first case has a simple rhs we can split this into two seperate
definitions.

```haskell
ins x [] = [x]

ins x (y:ys)
= case whatever of
_ | x < y -> x:y:ys
| x > y -> y : ins x ys
| x == y -> y:ys
```

In this case all pattern matching is done (x (y:ys)), and all that remains are the three comparisons.
So, the case-expression uses one wildcard pattern ( ), and it can have any expression (whatever) at its top-level

#### Whatever - Now a string
In the proof-checker, whatever is taken to be the string "guarded-if"
```haskell
ins x (y:ys)
= case "guarded-if" of
_ | x < y -> x:y:ys
| x > y -> y : ins x ys
| x == y -> y:ys
```
We can use a new “law” called GRDIF i to check if the ith guard is true, and then
replace it by its RHS.

#### Using Guarded-If
Show and tell: SetAsList.thr (insIntoSingle,lenDouble)
#### Case-Based Strategy syntax
```
STRATEGY CaseSplit <case-name>
	CASE 1 <br!> <expr1>
		SHOW <br?> <expr>
		<strategy> -- can be ANY strategy !
	END CASE 1
	...
	CASE N <br!> <exprN>
		SHOW <br?> <expr>
		<strategy> -- can be ANY strategy !
	END CASE N
END CaseSplit
```

#### New Case-Based Scheme
Case-based reasoning needs a proof-scheme in the same way that Induction does:
```
CASE-SCHEME <name>
CASE 1 <br?> <expr1>
...
CASE N <br?> <exprN>
EXHAUSTIVE <br?> <expr1> || ... || <exprN>
EXCLUSIVE 1 2 <br?> not(<expr1> && <expr2>)
...
-- use order 1 3 ; 1 4 ; ... ; N-2 N-1 ; N-2 N
...
EXCLUSIVE (N-1) N <br?> not(<exprN-1> && <exprN>)
```
Using Cases
Show and tell: SetAsList.thr (mbr after ins)