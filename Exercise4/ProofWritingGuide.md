# Guide to Writing Proofs in .thr Language

This document outlines the structure and syntax for creating and writing proofs in the `.thr` language, based on the provided examples and notes.

## 1. File Structure

Proof files typically have the `.thr` extension. A basic file structure looks like this:

```plaintext
THEORY <TheoryName>
IMPORT-THEORY <OtherTheory>
IMPORT-HASKELL <HaskellFile>

<Laws>

<Theorems>
```

*   **THEORY**: Declares the name of the theory (usually matches the filename).
*   **IMPORT-THEORY**: Imports definitions and laws from other `.thr` files (e.g., `Equality`, `Boolean`, `Arithmetic`, `List`).
*   **IMPORT-HASKELL**: Imports Haskell definitions from `.hs` files.

## 2. Defining Laws

Laws are named properties that are assumed to be true or have been proven elsewhere. They are used to justify steps in a proof.

**Syntax:**
```plaintext
LAW <name> <expression>
```

**Examples:**
```plaintext
LAW add_symm         x + y == y + x
LAW mul_right_unit   x * 1 == x
LAW len_cat          length (xs ++ ys) == length xs + length ys
```

## 3. Defining Theorems

Theorems are properties you intend to prove.

**Syntax:**
```plaintext
THEOREM <name>
    <expression>

STRATEGY <strategy-type>
    <proof-body>

QED <name>
```

*   The `<name>` after `THEOREM` and `QED` must match.
*   The `<expression>` is the boolean statement you are proving.

## 4. Proof Strategies

The `STRATEGY` keyword defines how you approach the proof. Common strategies include:

*   **ReduceAll**: Simplify the entire expression to `True`.
*   **ReduceLHS**: Simplify the Left-Hand Side (LHS) of an equality to match the Right-Hand Side (RHS).
*   **ReduceRHS**: Simplify the RHS to match the LHS.
*   **Induction**: Use mathematical induction (see Section 6).
*   **CaseSplit**: Split the proof into different cases (see Section 7).

## 5. Writing Proof Steps

A proof body consists of a sequence of expressions separated by justifications.

**Format:**
```plaintext
<expression_1>
= <justification_1>
<expression_2>
= <justification_2>
...
<expression_n>
```

### Justifications

Every step must be justified. Common justifications include:

*   **LAW <name>**: Apply a defined law.
*   **DEF <function>**: Apply a function definition from imported Haskell code.
    *   `DEF func.1` refers to the first pattern match clause of `func`.
*   **SIMP**: Use the built-in simplifier (evaluates arithmetic, boolean logic, etc.).
*   **IF <branch>**: Select a branch of an if-then-else expression.
    *   `IF 1`: Select the `then` branch (condition is True).
    *   `IF 2`: Select the `else` branch (condition is False).

### Modifiers

*   **Direction**:
    *   `l2r`: Apply the law/definition from Left to Right (default).
    *   `r2l`: Apply from Right to Left.
*   **Focus**:
    *   `@ <name> <index>`: Apply the change at a specific occurrence of a function or operator.
    *   Example: `@ + 2` applies to the second occurrence of `+`.
    *   Example: `@ len` applies to the first occurrence of `len`.

**Example Step:**
```plaintext
   ((x - (y - z)) * 1) - (0 + 0) == (((z + x) - y) * 1) + (0 - 0)
   = LAW mul_right_unit l2r @ * 1
   ((x - (y - z)) - (0 + 0)) == (((z + x) - y) * 1) + (0 - 0)
```

## 6. Induction

To prove properties for recursive data types (like Lists or Natural Numbers), use the `Induction` strategy.

**Syntax:**
```plaintext
STRATEGY Induction <variable> :: <Type>

BASE <base_value>
    <proof_for_base_case>
QED BASE

STEP <step_pattern>
ASSUME <hypothesis>
SHOW <goal>
    <proof_for_inductive_step>
QED STEP
```

**Example (List Induction):**
```plaintext
STRATEGY Induction xs :: List
BASE []
    <proof_body>
QED BASE

STEP (x:xs)
ASSUME P(xs)
SHOW P(x:xs)
    <proof_body>
QED STEP
```

## 7. Case Splitting

Used when a function behaves differently based on conditions (guards or if-statements).

**Syntax:**
```plaintext
STRATEGY CaseSplit <name>

CASE <label_1>
    <expression_1>
SHOW <goal_1>
    <proof_body>
END CASE <label_1>

CASE <label_2>
    <expression_2>
SHOW <goal_2>
    <proof_body>
END CASE <label_2>

END CaseSplit
```

## 8. Example Walkthrough (from Ex4Q1)

**Theorem:**
```plaintext
THEOREM ex4q1
   ((x - (y - z)) * 1) - (0 + 0) == (((z + x) - y) * 1) + (0 - 0)
```

**Strategy:** `ReduceAll`

**Steps:**
1.  **Simplify Multiplication**: `x * 1` is `x`.
    *   `LAW mul_right_unit l2r @ * 1`
2.  **Simplify Addition/Subtraction with 0**: `x + 0` is `x`, `x - 0` is `x`.
    *   `LAW add_left_unit`, `LAW sub_right_unit`, `LAW sub_zero`
3.  **Rearrange Terms**: Use associativity and commutativity.
    *   `LAW add_sub_assoc2`, `LAW add_symm`
4.  **Reflexivity**: Finally show `LHS == LHS`.
    *   `LAW eq_refl` -> `True`

## 9. Tips
*   **Check Definitions**: Look at the `.hs` file to see how functions are defined (order of patterns matters for `DEF func.1`, `DEF func.2`).
*   **Use SIMP**: `SIMP` is powerful for arithmetic (`18 - 5` -> `13`) and boolean logic.
*   **Focus Carefully**: If a law doesn't apply where you expect, check if you need to specify `@ name index`.
*   **One Step at a Time**: Make small changes in each step to keep the proof readable and correct.
