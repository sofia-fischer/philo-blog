---
title: "How Complex is my Code?"

date: 2026-04-04T10:20:44+02:00

draft: false

description: "A book take away for \"Code is for Humans\"."

tags: [ "Dev User Experience", "Metrics", ]

---

{{< lead >}}
A book take away for \"Code is for Humans\", with a couple of side tracks into linguistic and AI critique.
{{< /lead >}}

## What is Complexity?

> "Complexity of an algorithm is the amount of resources required to run it."

(Wikipedia Definition)

Given this definition, there are so many definitions of _Resources_ one can think of in terms of running code: the memory
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
of all possible values in the list up front for example would be faster with `O(n)`. This implementation would first
need `O(n)` for finding the max, then `O(n)` for looping through the values and placing them in the count array, and
again `O(k)` for the construction of the result where `k` is the highest value.

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

Analysing the number of operations that an algorithm might perform here gave a hint that the second algorithm could
be more performant. But in this case, it rises the question for which price? The first function was easy to
understand, as it is how many people intuitively sort - just start at one and place each next element on its spot in the
sorted part of the array. The second one is harder to understand, it creates a list that depends on the maximum
value which might unnecessarily big in a list like `[4500, 9000, 7200]`, and it is constraint because negative
numbers cannot be sorted.

For a software developer, just choosing an algorithm with a lower computational complexity might introduce a
different form of complexity by costing not computing-time-resources, but more time to understand the function, time
to document and communicate the limitations, time to fix if somebody used it for the wrong sets of numbers anyway.

### Domain Code Complexity

I define my job as writing business / domain code. For me, computing time or computer memory are cheap resources
compared to human thinking time and human memory. 50 initialized variables are a problem - not because the virtual
AWS machines I run my code on struggles - but because the developer who needs to spend hours every time they read the
function to understand the reason behind the 50 variables.

Therefor I ask - how can I measure, how complex my code is for a human?

Sure lines of code is a simplification of complexity, every one knows that many lines can be frustrating, but even
two lines can hide enough complexity to keep one occupied for hours.

### Cyclomatic Complexity

Cyclomatic Complexity counts the number of linearly independent paths through code; which means the number of each if,
for, while, case branches (plus 1, the method declaration).

There is solid research showing correlation between high Cyclomatic Complexity and defect density. A heatmap over the
repository can also identify why modules have high complexity, which can be great for a refactoring prioritization.
A function with a high Complexity is most likely more than it should and might benefit from giving away some of its
responsibility.
Also, it gives a nice basis to estimate how many and what tests are needed to cover a function in relation to it's
number of execution paths.

The Cyclomatic Complexity of `insertion_sort` and for `counting_sort` is 3 - both have two loops + 1. For this
example it looks like both implementation seem to have the same complexity. It doesn't capture semantic
complexity, background knowledge, or unintuitive limitations.

### Halstead Complexity

Halstead Complexity follows the idea that mental effort scales with the number of distinct concepts you need to hold in
working memory. Halstead argued that to understand a program, you need to learn each distinct operator, and on average
you need to see an operator twice to learn it (once to encounter it, once to confirm it). A program is more
difficult to understand the more distinct operands (`array`, `current` ...) it has that are rarely reused, and the
more distinct operators (`for`, `+`, `=`, ...) it has.

```python
HALSTEAD_LEARNING_CONSTANT = 2
# The variants of operators and operands making a function complex
halstead_difficulty = (distinc_operator_count / HALSTEAD_LEARNING_CONSTANT) * (total_operands / distinc_operand_count)

# The bits needed to encode the function in bits
halstead_volume = (total_operators + total_operands) * log_2(distinc_operator_count + distinc_operand_count)

# Estimated mental effort
halstead_cognitive_complexity = halstead_difficulty * halstead_volume
```

This gives for the two examples the result that the `counting_sort` is less difficult and (although higher volume)
is cognitively less complex.

```python
# insertion_sort
halstead_difficulty = (12 / 2) * (24 / 6) = 6 * 4 = 24
halstead_volume = 46 × log₂(18) = 46 × 4.17 = 192
# counting_sort
halstead_difficulty = (13 / 2) × (27 / 10) = 6.5 × 2.7 = 17.6
halstead_volume = 51 × log₂(23) = 51 × 4.52 = 230
```

While this is a very cool measurement of mental complexity, Halstead measures token reuse density, not conceptual
difficulty. The longer I think about this question, the more I think the answer is not in computer science, but in
linguistic.

## Linguistic Complexity

Psycholinguistics studies how humans process language and has identified some reliable predictors of reading difficulty:

* Familiarity — known words are processed faster than unknown ones. The equivalent in code is whether a pattern (like a
  sorting an array in an intuitive way) is immediately recognised or requires decoding. Here skill level can also
  matter, as programming patterns or even a new concept like `match` statements can be unfamiliar for individuals.
* Working memory load — sentences (and functions) with many nested clauses are harder because you have to hold
  unresolved structure in mind.
* Coherence — text is easier if each sentence connects clearly to the previous one. In code this can relate to the
  distance between a variable declaration and its usage, but also the goal of a function can be read as a mindful
  thought or a mess of statements.

### Linguistic Complexity measurements

Just looking superficial look into linguistic complexity compared to programming complexity revealed the shared
properties. Historically, both seem to have influenced each other, with natural language inspiring formal languages and
formal grammar as basis for compilers and vice versa programming complexities like Cyclomatic complexity inspiring parse
trees in linguistic, and many more interdependencies.

**Subordination index** Count of subordinate clauses which each add a new "branch" to parse.
_"If it rains, I will stay inside"_, has Subordination index of 2 because of the subordinal index _"if it rains"_ (
conditional). Mapping this to computer science it feels close to cyclomatic complexity, as it is not judging the
length of the sentence, but a new branch of information.

**Mean dependency distance (MDD)** Average syntactic distance between words and their governors (heads) across all
dependency pairs in a sentence or text. In dependency grammar, every word in a sentence depends on another word — its
governor (also called its head). The governor is the word that the dependent belongs to or modifies. In _"If it rains, I
will stay inside"_ "if" and "it" depend on "rains", everything else is dependent on "stay", which results in
`MDD = (2+1+3+1+1+1) / 6 = 9/6 = 1.5`. Which reminds me on Variable scope distance Lines between a variable's
declaration and its use. As in sentences, a function gets easier to read if variables are close defined to the line
that uses the variables, compared to first setup ten variables, and the using them over the next 20 lines of code.

**Dependency Locality Theory (DLT)** Storage cost of reading a sentences. The base idea is processing cost of
reading a sentence comes from holding incomplete dependencies open in working memory — specifically counting the number
of new discourse referents (roughly: nouns/verbs) you pass over while waiting for a dependency to close.
. _If it rains, I will stay inside_ has two resolving words ("rains", "stay"), so "I" and "will" need to say in memory
until one reads "stay" and resolve the current context, while "inside"only attaches to stay.
From the computers perspective I think mapping the "closing" of a context maps nicely to liveness of a variable. How
many lines or statements does a compiler need to track a variable until it becomes out of scope?
For humans on the other hand I find it much more intuitive to compare it to a functions call graph fan-out, how many
unresolved function calls do I need to comprehend while reading a function. A function that is calling `n` different
functions in it are a complexity increase for the reader who might need to understand those functions, but also a
coupling complexity as this function requires knowledge about the system.

**Type-token ratio** The count of unique words divided by the number of words, similar to Halstead vocabulary
because Halstead got inspired by linguistic ideas when developing his complexity metrics.

**Entropy** How unexpected is this word/sound given what came before? A cognitive claim states that reading and
understanding time scales with surprisal. It comes with the concept of perplexity, the number of equally likely
alternatives to continue at a position in text or code. Empirically this is measured reading time of humans or
using LLMs as probability estimators. Studies applying this to code have a hard time to compare the metric in both
fields - programmers do not read in a linear way, but jumps from function to caller to definition to parameter to
function.

### Natural Language Description Complexity

The conceptional complexity of a text or function is very hard to determine. One could argue a function is so
complex as the natural language description is, that describes what the function is doing.

This conflates Map with the territory - measuring the description of the abstraction does not necessarily reflect the
cognitive load of the code for the developer working with it. A famous example of something that developers might be
able to explain easily, but still cannot easily comprehend in code is the concept of a Monad in Haskell.

For which audience is the algorithm described? In what detail are business decisions described? Is by this measurement
the description of an algorithm for the formular`E = mc^2` as simple as "Energy equals mass times the speed of light
squared" or does this require a more complex natural language description? What amount of domain knowledge is expected
by the reading developer? If extreme knowledge about a topic can be assumed, even "low quality" code can have a low
perceived complexity - I once had the chance to read through the code of a geophysics academic, and the one-letter
variables and complex, undescribed functions where sufficient assuming the code reader where aware of the required
geo-physic formulas and definition (which inherently are defined by single-character constants).

**The cognitive complexity of a function can only be determined by the reader, and only caring about the reader can
enable the writer to improve the learning experience of the reader.**

## Working with Complexity Metrics

I experimented with complexity metrics on code
in [this Jupyter Notebook](https://github.com/sofia-fischer/complexity/blob/main/complexity.ipynb), feel free to use the
code for your own projects.

There are a couple of questions you can ask to interpret the metrics:

**Aggregation** Is the complexity of a module its ...

* sum of complexity of all functions to get an image of the overall complexity of a project? After all a bigger
  project is more complex than a small one.
* average of complexity of all functions to get the overall healthiness of a project, ignoring outliners?
* maximum complexity of all functions to identify the outliners, that are in desperate need fore simplification?

**Combining Metrics** Maybe complexity itself is not the issues, but

* Coupling - is a complex file easy to refactor because it is never imported and safe to change - or is it
  imported very often and must be stable and bug free?
* Churn - is a complex file changed regularly introducing bugs, and would provide a great gain if we could simplify
  it. Or doesn't it even mater because it is never touched - or is it so complex that it is never touched?

Like for all graphs (as learned
in [this post about Communication Patterns]({{< ref "/posts/2025-10-communication-patterns" >}})),
a graph should tell a story. Looking at metrics is
interesting, but it depends so much on your project if and which complexity is actual an issue.
What such graphs can for sure to, is to provide a visualization for non-tech people and be a basis for a
communication about need for refactor or technical debt; to identify a problematic code area or to proof the success
of a refactor with a before and after analysis.

Complexity metrics like all other metrics can be a tool. If developer are forced to improve it, it will not help the
codebase. If it is used to drive data based decision-making, and to convince managers with fancy graphics that
refactoring has a measurable impact, it can be a great help.

Happy Coding :)
