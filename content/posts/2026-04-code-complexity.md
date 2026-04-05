---
title: "How Complex is my Code?"

date: 2026-04-04T10:20:44+02:00

draft: false

description: "What code complexity can mean — from Big O notation and Cyclomatic Complexity to the surprising 
insights psycholinguistics can offer software developers."

tags: [ "Dev User Experience", "Metrics", ]

---

{{< lead >}}
What code complexity can mean — from Big O notation and Cyclomatic Complexity to the surprising
insights psycholinguistics can offer software developers.
{{< /lead >}}

## What is Complexity?

> "Complexity of an algorithm is the amount of resources required to run it."

(Wikipedia Definition)

Given this definition, there are so many definitions of _Resources_ one can think of in terms of running code: the
memory
needed, the time needed, the mental resources to understand the code, the mental resources required to understand the
problem, the context knowledge to understand how the code is solving it — all are reasonable interpretations of
resources required to run code.

### Computational Complexity

I had multiple lectures in university that pointed towards the question of "how complex is this code?". Starting with
formal definitions of a problem, how programs can be modelled to understand their resources, to the actual
computation of how resource usage (time or memory) grows as input size grows. Looking at these topics as a software
developer and no longer a computer science student, I only sometimes discover glimpses of those questions at work.

For example, the computational time complexity of this code would be `O(n²)`, with `n` the length of the list.
In the worst case of a reverse-sorted list, this would perform, for each of the n elements of the list, n comparisons to
the other list elements and then n swaps.

```python
def insertion_sort(array: list[int]) -> list[int]:
    for index in range(1, len(array)):
        current = array[index]
        predecessor = index - 1
        while predecessor >= 0 and array[predecessor] > current:
            array[predecessor + 1] = array[predecessor]
            predecessor -= 1
        array[predecessor + 1] = current
    return array
```

A different implementation solving the same problem can vary in computational complexity. Sorting by creating a map
of all possible values in the list up front, for example, would be faster with `O(n)`. This implementation would first
need `O(n)` for finding the max, then `O(n)` for looping through the values and placing them in the count array, and
again `O(k)` for the construction of the result, where `k` is the highest value.

```python
def counting_sort(array: list[int]) -> list[int]:
    count = [0] * (max(array) + 1)
    for current in array:
        count[current] += 1

    result = []
    for current, frequency in enumerate(count):
        result.extend([current] * frequency)

    return result
```

Analysing the number of operations that an algorithm might perform gave a hint that the second algorithm could
be more performant. But in this case, it raises the question: at what cost? The first function was easy to
understand, as it mirrors how many people intuitively sort — just start at one and place each next element in its spot
in the
sorted part of the array. The second is harder to understand: it creates a list that depends on the maximum
value, which might be unnecessarily large for a list like `[4500, 9000, 7200]`, and it is constrained because negative
numbers cannot be sorted.

For a software developer, simply choosing an algorithm with a lower computational complexity might introduce a
different form of complexity, costing not computing-time resources, but more time to understand the function, time
to document and communicate its limitations, and time to fix issues if somebody used it with the wrong sets of numbers.

### Domain Code Complexity

I define my job as writing business / domain code. For me, computing time and computer memory are cheap resources
compared to human thinking time and human memory. 50 initialised variables are a problem, not because the virtual
AWS machines I run my code on struggle, but because the developer who needs to spend hours every time they read the
function to understand the reason behind the 50 variables.

Therefore, I ask, how can I measure how complex my code is for a human?

Sure, lines of code is a simplification of complexity — everyone knows that many lines can be frustrating, but even
two lines can hide enough complexity to keep one occupied for hours.

### Cyclomatic Complexity

Cyclomatic Complexity counts the number of linearly independent paths through code — that is, the number of `if`,
`for`, `while`, and `case` branches (plus 1 for the method declaration).

There is solid research showing a correlation between high Cyclomatic Complexity and defect density. A heatmap over the
repository can also identify why modules have high complexity, which can be great for refactoring prioritisation.
A function with high complexity is most likely doing more than it should, and might benefit from delegating some of its
responsibility.
It also gives a nice basis for estimating how many tests are needed to cover a function, in relation to its
number of execution paths.

The Cyclomatic Complexity of both `insertion_sort` and `counting_sort` is 3 - both have two loops + 1. For this
example, both implementations appear to have the same complexity. It doesn't capture semantic
complexity, background knowledge, or unintuitive limitations.

### Halstead Complexity

Halstead Complexity follows the idea that mental effort scales with the number of distinct concepts you need to hold in
working memory. Halstead argued that to understand a program, you need to learn each distinct operator, and on average
you need to see an operator twice to learn it (once to encounter it, once to confirm it). A program is harder
to understand the more distinct operands (`array`, `current`, ...) it has that are rarely reused, and the
more distinct operators (`for`, `+`, `=`, ...) it has.

```python
HALSTEAD_LEARNING_CONSTANT = 2
# The variety of operators and operands that make a function complex
halstead_difficulty = (distinct_operator_count / HALSTEAD_LEARNING_CONSTANT) * (total_operands / distinct_operand_count)

# The bits needed to encode the function
halstead_volume = (total_operators + total_operands) * log_2(distinct_operator_count + distinct_operand_count)

# Estimated mental effort
halstead_cognitive_complexity = halstead_difficulty * halstead_volume
```

This gives the result that `counting_sort` is less difficult and, although it has a higher volume, is cognitively less
complex.

```python
# insertion_sort
halstead_difficulty = (12 / 2) * (24 / 6) = 6 * 4 = 24
halstead_volume = 46 × log₂(18) = 46 × 4.17 = 192
# counting_sort
halstead_difficulty = (13 / 2) × (27 / 10) = 6.5 × 2.7 = 17.6
halstead_volume = 51 × log₂(23) = 51 × 4.52 = 230
```

While this is a very cool measurement of mental complexity, Halstead measures token reuse density, not conceptual
difficulty. The longer I think about this question, the more I think the answer lies not in computer science, but in
linguistics.

## Linguistic Complexity

Psycholinguistics studies how humans process language and has identified some reliable predictors of reading difficulty:

* **Familiarity** known words are processed faster than unknown ones. The equivalent in code is whether a pattern (like
  sorting an array in an intuitive way) is immediately recognised or requires decoding. Skill level also
  matters here, as programming patterns or even new concepts like `match` statements can be unfamiliar to individuals.
* **Working memory load** sentences (and functions) with many nested clauses are harder because you have to hold
  unresolved structure in mind.
* **Coherence** text is easier when each sentence connects clearly to the previous one. In code, this can relate to the
  distance between a variable declaration and its usage, but also to whether the goal of a function reads as a clear
  thought or a mess of statements.

### Linguistic Complexity Measurements

Even a superficial look into linguistic complexity compared to programming complexity reveals shared
properties. Historically, both seem to have influenced each other. Natural language inspiring formal languages and
formal grammar did form the basis for compilers, and vice versa, programming complexities like Cyclomatic Complexity
inspired parse trees in linguistics; to just name one of many examples.

**Subordination index** Count of subordinate clauses, each of which adds a new "branch" to parse.
_"If it rains, I will stay inside"_ has a Subordination index of 2 because of the subordinate clause _"if it rains"_ (
conditional).
Mapping this to computer science, it feels close to Cyclomatic Complexity, as it judges not the length of the sentence,
but the addition of a new branch of information.

**Mean Dependency Distance (MDD)** Average syntactic distance between words and their governors (heads) across all
dependency pairs in a sentence or text. In dependency grammar, every word in a sentence might depend on another word
called its governor. The governor is the word that the dependent belongs to or modifies. In _"If it rains, I
will stay inside"_, "if" and "it" depend on "rains", and everything else is dependent on "stay", which results in
`MDD = (2+1+3+1+1+1) / 6 = 9/6 = 1.5`.
This reminds me of variable scope distance; the number of lines between a variable's declaration and its use. As in
sentences, a function is easier to read when variables are defined close to where they are used, compared to setting up
ten variables upfront and then using them over the next 20 lines of code.

**Dependency Locality Theory (DLT)** Storage cost of reading a sentence. The core idea is that the processing cost of
reading a sentence comes from holding incomplete dependencies open in working memory — specifically, counting the number
of new discourse referents (roughly: nouns/verbs) you pass over while waiting for a dependency to close.
_"If it rains, I will stay inside"_ has two resolving words ("rains", "stay"), so "I" and "will" need to be held in
memory
until one reads "stay" and resolves the current context, while "inside" only attaches to "stay".
From a computer science perspective, the "closing" of a context maps nicely to the liveness of a variable: how
many lines or statements does a compiler need to track a variable until it goes out of scope?
For humans, I find it more intuitive to compare it to a function's call graph fan-out — how many
unresolved function calls must I hold in mind while reading a function? A function that calls `n` different
functions increases complexity for the reader, who may need to understand each of those functions, and also introduces
coupling complexity, as this function requires knowledge about the broader system.

**Type-token ratio** the count of unique words divided by the total number of words, similar to Halstead vocabulary,
since Halstead was inspired by linguistic ideas when developing his complexity metrics.

**Entropy** how unexpected is a given word or sound given what came before? A cognitive claim states that reading and
understanding time scales with surprisal. It comes with the concept of perplexity — the number of equally likely
alternatives to continue at a given position in text or code. Empirically, this is measured via the reading time of
humans or using LLMs as probability estimators. Studies applying this to code have a hard time comparing the metric
across both fields — programmers do not read in a linear way, but jump from function to caller to definition to
parameter to function.

### Natural Language Description Complexity

Beyond measurable syntax and structure, the conceptual complexity of a text or function is very hard to determine. One
could argue a function is as complex as the natural language description of what it does.

This conflates the map with the territory. Measuring the description of an abstraction does not necessarily reflect the
cognitive load of the code for the developer working with it. A famous example of something developers might be
able to explain easily but still cannot easily comprehend in code is the concept of a Monad in Haskell.

For which audience is the algorithm described? In what detail are business decisions explained? By this measure,
is the description of an algorithm for the formula `E = mc²` as simple as "Energy equals mass times the speed of light
squared", or does it require a more complex natural language description? What amount of domain knowledge is expected
of the reading developer? If extensive knowledge about a topic can be assumed, even "low-quality" code can have low
perceived complexity. I once had the chance to read through the code of a geophysics academic where one-letter
variables and complex, undescribed functions were sufficient, assuming the reader was familiar with the required
geophysics formulas and definitions (which are inherently defined by single-character constants).

**The cognitive complexity of a function can only be determined by the reader, and only caring about the reader can
enable the writer to improve the learning experience.**

## Working with Complexity Metrics

I experimented with complexity metrics on code
in [this Jupyter Notebook](https://github.com/sofia-fischer/complexity/blob/main/complexity.ipynb). Feel free to use
the code for your own projects, but mind that this was my first time working with polars and dataframes.

There are a few questions you can ask when interpreting the metrics:

**Aggregation** is the complexity of a module its...

* sum of complexity of all functions, to get a sense of the overall complexity of a project? After all, a larger
  project is more complex than a small one.
* average complexity of all functions, to get a sense of the overall health of a project, ignoring outliers?
* maximum complexity of all functions, to identify the outliers that are in most need of simplification?

An example of complexity aggregated by maximum of the django framework codebase:

![Complexity Sunburst by Maximumg](/images/2026-04-complexity-cyclomatic.png)

**Combining Metrics** maybe complexity itself is not the issue, but rather:

* **Coupling** is a complex file easy to refactor because it is never imported and safe to change? Or is it
  imported very often and must therefore be stable and bug-free?
* **Churn** is a complex file changed regularly, introducing bugs, such that simplifying it would provide a great
  gain? Or does it not matter because it is never touched? Or is it so complex that nobody dares touch it?

An example of complexity combined with churn and afferent coupling of the django framework codebase:


![Complexity Scatter with Churn and Coupling](/images/2026-04-complexity-churn.png)

Like all graphs (as discussed
in [this post about Communication Patterns]({{< ref "/posts/2025-10-communication-patterns" >}})),
a graph should tell a story. Looking at metrics is interesting, but it depends heavily on your project whether, and
which, complexity is actually an issue. What such graphs can reliably do is provide a visualisation for non-technical
stakeholders and serve as a basis for conversations about refactoring needs or technical debt, enable other to
identify a problematic area of the codebase, or to demonstrate the success of a refactor with a before-and-after
analysis.

Complexity metrics, like all other metrics, are a tool. If developers are forced to improve them, it won't help the
codebase. But if they are used to drive data-based decision-making, and to convince managers with clear visualisations
that refactoring has a measurable impact, they can be a great help.

Happy Coding :)
