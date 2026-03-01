---
title: "📚 Book takeaways Refactoring by Martin Fowler"

date: 2026-02-28T10:20:44+02:00

draft: false

description: "A classic book by Martin Fowler about refactoring, providing a collection of code smells and refactoring techniques to
improve them"

tags: [ "Development", "Software Pattern", "Book"]

---

{{< lead >}}
A classic book by Martin Fowler about refactoring, providing a collection of code smells and refactoring techniques to
improve them.
{{< /lead >}}

{{< alert "comment" >}}
In these call-outs I flag my personal opinion or additions.
Like for other books, this post reflects my learnings and opinions. It does not aim for a true representation or summary
of the book. Some chapters (like the one about self-testing code) are missing completely, because I honestly did not
feel like this book is a good way to learn about tests compared to books which are focused on modern test strategies.

I very much changed the structure of the book. As a reader I may enjoy the freedom of reading it the way I
please and find easy to follow, regardless on the structure the author envisioned.
In this case this means, Martin Fowler offered one chapter of code smells linking to
the following chapters of categorized ways of refactoring with examples; while I will present here a selection of code
smells with examples and the best fitting refactorings to fix them. The code examples are all self designed code smell
asci monsters (even if they look like a tree).
{{< /alert >}}

## Refactoring

Refactoring is a code change that does not change the external behavior of the Code.

It should be driven by change, not by personal opinions on code aesthetics.

Reasons and moments to refactor could be:

* If a new feature should be implemented, and there is no simple way to add the new code
* Reducing the future cost of change. Modularity can improve the speed in which new functionality can be added (if we
  are aware of the upcoming functionality)
* Emphasize architecture decisions that sometimes get buried under short term decisions
* Comprehensive Refactoring to understand complicated code
* Litter pickup to allways leave the code cleaner that you encountered it
* Refactor as review style

Refactoring can allways be performed step by step, with reliable tests running, and do not need a massive change of the
code base with hours of trying to get a now completely different code running to the same tests. Every refactoring is
possible in a loop of one line change, tests passing, and the next one line change. Need to refactor a property into a
getter? Write the getter, replace property access by property access with the getter. Need to extract a function (and
don't want to use the IDEs refactor function)? Move it line by line into the function, while keeping the tests passing.
Having a hard time with many variables? Replace them with function calls during refactoring to enable you to move slowly
with passing tests.

Because refactoring does not change the external behavior, it can be completely separated from feature development,
coining the phrase `First make the change easy, then make the easy change`. This emphasizes feature adding and
refactoring are two steps, valuing different skills and knowledge, and aiming for different goals - different jobs that
can be imagined as two hats be worn to different occasions, never simultaneously.

{{< alert "comment" >}}
I even would add a Optimization hat for even another job: identifying and improving bottlenecks in a system. 
{{< /alert >}}

![Cowboy Refactoring hat, Code Wizards Cylinder, Optimization Artist Beret](/images/2026-02-refactoring.png)

### Refactoring and Performance

Most performance issues are located in a very small fraction of the code. Most of the time, refactoring makes it easier
to identify and tackle those bottlenecks, which in practise is often more relevant than performance drawbacks from
refactoring e.g. running through the same loop twice to separate two steps of processing.

{{< alert "comment" >}}
In most cases, replacing a variable with a query does not harm the performance in a way that matters, but it can be a
good idea to check if the query is expensive to execute before doing this refactoring. By expensiveness, I don't mean
algorithmic complexity growing from O(n) to O(2n), but more excessive database queries that cost measurable amounts of
resources in a software system.

Many arguments regarding performance because of refactorings in my experience are not based on actual measurements, but
rather on a gut feeling, that often not even accounts for the languages / compiler specific optimizations. If a
refactoring causes a measurable performance decrease (to which I would call number of database queries), then the
refactoring is questionable.
{{< /alert >}}

## Code Smells

### Mysterious Name

Naming is hard, and renaming a function, property, or variable is one of the most common refactorings. While it is easy
to call out "rename it" as a solution, complicated names can often be a sign of deeper design issues.

{{< alert "comment" >}}
I am a big fan Ubiquitous Naming, one of the core principles of Domain Driven Design. Concepts in code should be named
how the user would name the concept when using the software. If there is something in the code, that the developer has a
hard time to name, and the user does not have a clear name for it, maybe it indicates that it should not be in the code
at all?
{{< /alert >}}

```python
def caliginous_string() -> str:
    return (f"""
      -------
      │  ?  │
    dbqpdbqpdbq
      ( o.o )
      @≥ - ≤@
    """)
```

#### Change the declaration of a function, property or variable

Functions represents building blocks of the software system. A well-defined function name can replace the need of
finding out what the function does and how it is used. This also applies to parameters, properties and variables - a
clear names enables the future developer to understand the code, its purpose and how it is used without needing to read
the implementation. The more widely something is used, the more important is the clarity of its name.

### Duplicated Code

Using the same code in multiple places can indicate a missed opportunity for abstraction. Abstracting would emphasize
the differences between similar code, instead of costing the reader time to question if there is a difference.
If the difference might even be big and consistent enough to
be [separated into multiple functions](#extract-a-function).

To ensure euphoric deduplication is not making the code more complex than it needs to be, the "Rule of three" can
be used as a guidance to allow duplications until at least three variants did present themselves to understand how
different variants might behave.

```python
def twin_monster() -> str:
    return (f"""
      -------
      │  ?  │
    dbqpdbqpdbq
      ( ^.^ )
      @≥ - ≤@
    """)
```

#### Slide (Move) Statements

Code is easier to understand when related statements are close to each other. Sliding statements means moving statements
together. This can be a preparation for an [Extract Function](#extract-a-function).

### Long Function

A long function hides where the main logic is defined, and will cause every reader time to parse through the entire
function to understand it and where the new feature should be placed. This can be avoided by shortening and structuring
the function in way, that makes it easy to understand and place a new feature. The main goal should not be to reach a
maximum line number a function should have, but to separate intention and implementation. A function should have a
specific reason and context to exist in, which might be a concrete implementation, or stating an intention that calls
implementations.

```python
from datetime import datetime


def long_function_monster() -> str:
    now = datetime.now()

    # Start building the snake
    snake = "    ___   \n"
    snake += "  >{_σ │  \n"

    # Changed to left turning snake by 2020
    if now > datetime(2020, 3, 15):
        snake += "      \ \  \n"

    # Rolling release in 2025
    if now > datetime(2025, 11, 1):
        snake += "   ____) )\n"
        if now < datetime(2025, 1, 10):
            snake += " / _____/ \n"
        if now < datetime(2025, 3, 1):
            snake += "( (___    \n"
        if now < datetime(2025, 5, 1):
            snake += " \___ \   \n"
        if now < datetime(2025, 7, 1):
            snake += "     \/   \n"

    # Feature flag with auto enable in 2022
    if now < datetime(2022, 6, 20):
        snake += " \___ \   \n"
        if now > datetime(2022, 9, 1):
            snake += "     \/   \n"
        else:
            snake += "  ___/ /  \n"

    if now > datetime(2023, 2, 14):
        snake += " / _____/   \n"

    if now < datetime(2023, 7, 4):
        snake += "( (___ __ \n"
        if now > datetime(2023, 10, 31):
            snake += " \_____  \\n"
            # Parse the override string
            pass

    # Special handling for empty results (added for client X)
    if now < datetime(2024, 4, 1):
        snake += " / _____/ \n"

    # Tail handling
    snake += "( (___    \n"
    snake += " \___ \   \n"
    snake += "     \/   \n"

    return snake
```

Similar to this, **Large classes** cause the same problems, which might or might not allow the [extraction of whole
class](#extract-class). Additionally, here identifying
and [replacing possible subclasses with different types](#replace-conditional-with-polymorphism) might help, this way
properties and functions that only belong to some subtypes are moved out of the way to only leave the things that are
common and used among all subclasses.

#### Extract a Function

A function symbolizes a differentiation between intent and implementation. Extracting a function means replacing the old
code fragment with a function call named after the intent of the code fragment. The parameters of the extracted function
highlight dependencies and differences between its usages. With this goal in mind, having a function that just hase one
line of code can be valid if it describes the intent of the code fragment better than the code fragment itself. In that
way extracting a function can replace the need of a comment.

A large block of code can have a clearer intention if the code blogs within conditionals are extracted, leaving just the
conditional easily readable in the original function. How the conditions are structured can also have drawbacks and
benefits. Sometimes it is a clean solution to have on consolidated check that replaces a big nested check can make
things easier to understand than a big conditional with many branches.

Pulling up a method means moving a method from a subclass to its superclass. This is useful when the method is
duplicated in multiple subclasses, or only differs in small parts, naming, or parameters.

One hint, that a function is too long and should be splitted. If a variable is the result of a complex calculation, but
is then re-assigned, that can be a sign that the function and that variable is doing too much and might work better
splitted.

#### Replace Variable, Property, or Parameter with Query

Variables or Parameters can capture and name a value, but they also introduce something the developer needs to keep in
mind. Replacing variables with small functions can make the code easier to read and to perform other refactorings
because the local dependency of the variable is removed.

Replacing properties with queries can also remove mutable data that can also be calculated freshly, removing any danger
to corrupt or stale the value.

Replacing a variable with a query only makes sense if the redone calculation of the variables will not change the
outcome. While formatting for example would allways produce the same result, a database query might produce different
results each time it is executed (which can be intentional in the same function, but sometimes is not).

#### Replace Function with Command

A command in this context is a function that is encapsulated into an object. In this form, the function can have its own
set of subfunctions and properties. This can be useful when the function is too complex to be easily understood, or when
it is intended to be used as a single unit of work that can be executed, undone, or queued.

#### Replace Conditional with Polymorphism

Complex conditional logic is often the hardest thing to code in a readable, intuitive way. One way to solve this is to
separate the conditions into different circumstances that are wrapped into different subclasses, each handling an
understandable subset of the conditional logic. This can be Variants with given parameter options, variants that match
certain assumptions, or variants that belong to different types.

#### Split Loop (intp Pipeline)

It is a common anty pattern that a loop is used to do things at the same. This comes with the drawback, that whenever
the loop is touched, both things need to be understood. Splitting such a loop into two loops, each doing its own task,
can be a good solution for that. Many hesitate to do this because of performance concerns, which are covered
in [Refactoring and Performance](#refactoring-and-performance)

If that loop does multiple things, this can be further clarified by using Pipelines like Map, Filter, Reduce to further
emphasise how the data is processed.

### Long Parameter List

Long parameter lists happen, sometimes for historic reasons, sometimes because more and more functionality was added
over the iterations. It indicates in any case that the behavior of functions may vary in many ways, which ways exactly
is obfuscated by the number of variables that the reading developer needs to keep in mind to parse the function.

One straight forward way is to [replace a Parameter with Query](#replace-variable-property-or-parameter-with-query) to
reduce the number of parameters, although this would keep the coupling.

```python
def parameter_hungry_monster(
        has_teeth: bool,
        teeth_count: int,
        tongue_count: int,
        tonsils: bool,
        extra_jaw_size: int,
) -> str:
    teeth_count = max(min(teeth_count, 5), 0)
    monster = " _" + "_" * teeth_count + "δδ) \n"
    monster += "() " + " " * teeth_count + " | \n"
    monster += "  " + ("v" if has_teeth else "~") * teeth_count + "\ |\n"
    if tonsils:
        monster += " " * teeth_count + "   |│\n"
    for tongue in range(tongue_count):
        monster += " >≈" + "≈" * teeth_count + "|│\n"
    for extra_jaw_size in range(extra_jaw_size):
        monster += " " * teeth_count + "   |│\n"
    monster += " (" + "^" * teeth_count + "  │ \n"
    monster += " " * teeth_count + "ΣΣ ß"
    return monster
```

#### Introduce Parameter Object

Often a set of parameters travel together even through multiple functions. Such data clump can be replaced by a data
class, emphasizing their relationship. Also, this will make the code more consistent and reducing the parameter list.
They also open up the possibility to restructure the code around this new-found abstraction.

It sometimes happens that a couple of properties of an object are separated just to be put into one function. This is
prone to future touches as any change of the object might require touching the function. This can be avoided if the
whole object would become the parameter. Although sometimes the dependency to the object can be a problem itself.

Another example of replacing parameters is replacing boolean flag arguments with more meaningful enums, even replace
other parameters.

#### Combine Functions into Class

Classes bind functions together in a shared environment, exposing some behavior for outside functions to interact.
Moving sets of functions into a class makes the shared environment they act in visible.

### Mutable Data

Mutable data often leads to a change of data here causes unintended side effects in a different place.
The easiest, but not always straight forward solution is to prefer values to references. Instead of changing data
objects, they then should be re-instantiated with the new values.

One way to solve this is to [extract the re-instantiation into a function](#extract-a-function)
or [replacing the mutable
variable directly with a query](#replace-variable-property-or-parameter-with-query).

{{ <alert "comment"> }}
Rust does a great job in sensitizing one on the restrictions of mutable data. In Rust everything is immutable by
default, requiring the dev to explicitly declare it as mutable. Even pointers may be mutable or not.

Rust has the concept of Ownership - every object has an owner that may the only one who may mutate a mutable object.
This again causes more friction for the developer, forcing them to be conscious about mutability and hinting towards
queries over variables.
{{ </alert> }}

```python
def mutable_data_monster() -> str:
    monster = (" ,---.\n"
               "( @ @ )\n"
               " ).-.(\n"
               "'/|||\`\n"
               ") '|` (\n")
    return _bubbly(_mutate_tentacle(monster))


def _mutate_tentacle(monster: str) -> str:
    monster = monster.replace("|||", "( )")
    monster = monster.replace("/", ")")
    return monster.replace("\\", "(")


def _bubbly(monster: str) -> str:
    monster = monster.replace(".", "~")
    monster = monster.replace("`", ")")
    monster = monster.replace("'", "(")
    return monster.replace(",", "●")
```

#### Encapsulate Variable into a function

Data is trickier to refactor than functions, as functions can be easily called from multiple places through multiple
functions; but changing a data structure often requires change in all cases in which the data is accessed. This is why
routing access to a mutable data property can be routed through a function (like an accessor / getter function) allows
for easier refactoring in the future.

The next step to this would be to remove setting methods to replace them by enforcing settings on initialisation, making
the configuration of a class immutable. If that initialisation becomes more and more complex a factory function can help
to organise the initialisation of classes in a readable and flexible way.

{{< alert "comment" >}}
Even some patterns like Builder pattern can help here to collect the information needed to initialise a function in
multiple places.
{{< /alert >}}

#### Separate Query from Modifier

The differentiation between functions with and without side effects - Commands and Query Separation.
A common pattern is that functions that return a value should not have side effects (queries).

### Divergent Change

Divergent Change happens if a module is touched for many reasons. If a class or function has too many responsibilities,
it needs changes often and becomes harder to understand as it touches multiple contexts. The goal here is straight
forward to sort the different contexts into different places in a way that allows the developer to ignore the rest when
changing just one context.

{{< alert "comment" >}}
A nice way of identifying a file that suffers from this code smell can be a combination of Cyclomatic Complexity and
change frequency. Spots of high complexity and frequent change often indicate that a nicer abstraction / partition is
needed.
{{< /alert >}}

```python
from typing import Literal


def divergent_monster(phase=Literal["Protocell", "Prokaryote", "Eukaryote"]) -> str:
    membrane = get_membrane(phase)
    core = get_cell_core(phase)
    extra = get_mitochondrion(phase)

    monster = (f"       {membrane}{membrane}  {membrane}\n"
               f"     {membrane}       {membrane}\n"
               f"  {membrane}            {membrane}\n"
               f"{membrane}                 {membrane}\n"
               f"{membrane}     {core}{core}{core}             {membrane}\n"
               f"{membrane}    {core}  {core}{core}       {extra}    {membrane}\n"
               f"{membrane}     {core}{core}{core}                {membrane}\n"
               f"{membrane}                       {membrane}\n"
               f" {membrane}       {extra}      {extra}    {membrane}\n"
               f"    {membrane}             {membrane}\n"
               f"     {membrane}      {membrane}\n"
               f"       {membrane}{membrane}{membrane}\n")
    return monster


def get_membrane(phase=Literal["Protocell", "Prokaryote", "Eukaryote"]) -> str:
    match phase:
        case "Protocell":
            return "  "
        case _:
            return "||"


def get_cell_core(phase=Literal["Protocell", "Prokaryote", "Eukaryote"]) -> str:
    match phase:
        case "Eukaryote":
            return "▒"
        case _:
            return " "


def get_mitochondrion(phase=Literal["Protocell", "Prokaryote", "Eukaryote"]) -> str:
    match phase:
        case "Prokaryote":
            return " "
        case _:
            return "⬤"
```

#### Split Phase

If a function or class models a process or sequence of steps, those steps can be separated into different phases. This
can if the steps in question happen by business logic and are called in an order, the phases are needed for technical
reasons like a compiler requiring parsing as a separate step. The first step in this direction would be [extracting a
function per phase](#extract-a-function).

#### Reorganise or Move

To separate different context not only programmatically but also visibly they can be moved into different modules,
files, classes. This can be valid for moving fields, functions, classes. This should leave only the relevant code in the
view of the developer or the functions that call it, but also gather all needed code in one place.

{{< alert "comment" >}}

This reminds to the clean-up rules of "Family, Friends, Coworkers" for physical objects. A beany hat might be placed
with its family of other beany hats, with its friends of all sorts of head covers, or with its coworkers the set of
gloves, shoes, jacket that are currently the daily things needed to go outside.

A function making a database query might live with its family in a query builder for a specific model, or with its
friends in a repository next to queries that might also call other models, directly in business code.

{{< /alert >}}

#### Extract Class

Similar to extracting functions, a class might often be too big to be understood. Indicators of where to split a class
are sets of functions that rely on the same set of properties or data, sets of function that are always called together,
or sets of function that are called for subtypes of the class.

### Shotgun Surgery or Feature Envy

This smell is the opposite of the [Divergent Change](#divergent-change), it is code that if you want to make one change
to, you have to go to many places to do that change. When those changes are scattered over multiple files and classes,
it is time costly to find and easy to miss one of them. Sometimes [reorganisation](#reorganise-or-move) is not straight
forward to do.

```python
def shotgun_monster(name: str) -> str:
    """
    Todo: Customer requested that the cat should have whiskers
    """
    ears = " /\_/\ \n"
    face = "( o.o )\n"
    legs = "(n   n)"
    if name.endswith("a"):
        ears = " /\_/@ \n"
    if "Sir " in name or "Lady " in name:
        face = "( δ.δ )\n"
    if len(name) > 10:
        legs = "| || |\n(∞   ∞)=======//"
    if name.startswith("Big"):
        face = "(  o.o  )\n"
        legs = "( Ω   Ω )"

    return ears + face + legs
```

#### Combine Functions into Transform

The goal of this refactoring is to identify if multiple derived properties of a data instance are used and requested in
multiple spots in the code. A single function or class is introduced to calculate all derive properties and hold them in
one object to be used throughout the code. This makes it easier to track how different derived properties affect the
data flow in the code and makes it easy to add features.

In a extreme form, this can lead to
the [combination of all the functions into one new class](#combine-functions-into-class).

#### Inline Function, Variable, or Inline Class

This is the opposite of extracting a function or class - copying the the body to all occurrences in which the function
would be called. This can sometimes help to restructure the class or function design completely and can free one from
the past refactoring decisions made.

### Feature Envy

Feature Envy can be a subset of this smell. Programs are usually modularized into parts with high cohesion, minimizing
interaction between code of different zones. If a function spends more time communicating with code in different modules
that can be a code smell and the code should be [restructured](#reorganise-or-move).

```python
def envy_monster() -> str:
    bark = get_membrane("Eukaryote")
    leaf = get_mitochondrion("Eukaryote")
    return (f"  {leaf}{leaf}  {leaf}\n"
            f"{leaf} {leaf} {leaf}{leaf}\n"
            f"  {leaf}{leaf} {leaf}\n"
            f"    {bark}\n"
            f"    {bark}\n"
            f"    {bark}\n")
```

### Data Clumps

If the same data items show up throughout the code, they might belong together, especially if they only make sense
with all present they should
be [encapsulated into their own class](#extract-class) or [object](#introduce-parameter-object) to emphasize their
combined meaning.

### Primitive Obsession

Primitives are the basic typing foundations provided in programming - integers, floats, strings, booleans in more or
less granulated types are common. Slightly more defined types are welcomed, like dates or currencies. But many
developers seem to avoid creating dataclasses that hold primitives with a meaning like coordinates that come in pairs of
floats between 0 and 360, ranges that imply start is smaller than end, or distance that hold a unit. Such different
types can be [refactored into Polymorphism](#replace-conditional-with-polymorphism)

For the practice of passing strings around, although custom types seem way more appropriate the term "stringly typed" is
coined.

```python
def primitive_monster(length: int) -> str:
    assert length > 0
    assert length <= 255
    assert length % 2 == 0
    return (" )  (\n"
            f"( '_'){'} ' * length} \n"
            f"      {'^ ' * length} \n")
```

#### Replace Primitive with Object

Packing a primitive into an object provides a single point of validation, data extraction, and defines the value.
Objects can answer the questions about the data like "is this `amount` in cent or euro?", "Do telephone numbers allways
include a country code?", "Can this `length` be negative?". Such objects also provide space for comparing or
calculating. This is strongly tied, but not limited to [Parameter Objects](#introduce-parameter-object)

### Speculative Generality

There are cases in which the code is made more flexible that it really needs to be. Sometimes because a refactoring
aimed for features that never came, sometimes because business mentioned featured that never reached the code but their
preparation did, sometimes a developer is eager to implement a pattern that is too complex for the current code.

Code that is not reachable can be removed. Version control system enable us to just delete code, not just commenting
them out. If removing code enables, then also the unused (or now always
equal) [function parameters should be removed](#change-the-declaration-of-a-function-property-or-variable)

```python
from abc import ABC


class Monster(ABC):
    identifier: str

    def draw(self) -> str:
        pass


class SpeculativeMonster(Monster):
    identifier: str = 'SpeculativeMonster'

    def draw(self) -> str:
        return self.speculative_monster()

    @staticmethod
    def speculative_monster() -> str:
        return (f"""
   .-----.   
 /         \ 
|\/(o) (o)\/|
|           | 
 \         / 
   \_____/
        """)
```

#### Collapse Hierarchy

If a class hierarchy is no longer needed, remove them. Changes to the parent class allways affect children - if this
behavior is causing more work than benefits, an interface might provide the same benefits without the strong coupling.
Work step by step and move all functions from the parent to the child in question, and remove the heritage.
Collapse Hierarchy

### Message Chains or Middle Mans

Following the flow of data sometimes reveals a series of getters. Navigating this path of getters means the original
client caller is coupled to each class stepped through. Often this can be simplified by
the [extraction of these methods](#extract-a-function) to a place in which multiple clients may access the data.

A special case of this would be a Middle Man, a class that only offers or redirect delegates. Maybe the class had a
reason to exist in the past, or some idea of encapsulation got carried out a bit too much. One first step might be to
[inline the functions](#inline-function-variable-or-inline-class) and see if the class is actually bringing benefit.

```python
class Client:
    def get_output(self) -> str:
        return Service().get_monster().speculative_monster()


class Monster:
    def speculative_monster(self) -> str:
        return (f"""
     \ ________
      |          \  
     /_/~~~~| |\ /9`\__‚  
    |b      |b   \/~~~~/
            """)


class Service:
    def get_monster(self) -> Monster:
        return Monster()
```

#### Hide Delegate

Is some client code calls a method that is defined on an object provided by some service, the client requires knowledge
about the delegate object. This coupling can be removed by adding a function on the service that will call the method of
the delegate and only returns its result, hiding the delegate. Changes made to the delegate do not propagate to the
(or even multiple) client(s), only to the service.

#### Replace Middle Man by Delegate

If I hide a delegate too often, this can also cause a lot of code that is hard to maintain, especially the class used to
hide the delegate does not provide any other benefit. Then a getter function may be introduced to get the whole object
and all get_delegate_property functions may be replaced by that.

This can applicable as well for Superclasses. If it does not make sense for a subclass to use or overwrite all the
functions of its superclass, it might be that inheritance is too strong of a coupling, and a delegate object instead of
a superclass might be more fitting. Same for the subclass if more axes variations is needed than practical for
inheritance, or is the coupling between subclasses causes problems.

### Alternative classes with different interfaces

One of the best benefits of classes are the option to substitute classes. Matching interfaces (so matching function
declarations) allow substitution in the long term and helps to find patterns in the current code.

{{< alert "comment" >}}
How I miss Dependency Injection with different classes 🥲 But honestly I did not really cross a two classes that itched
to follow the same interface when that was not intended from the very beginning.
{{< /alert >}}

### Comments

If you need a comment to explain what the code does it either has
a [bad name](#mysterious-name), [can be a function](#extract-a-function), or should
be [encapsulated and validated by a dataclass](#replace-primitive-with-object).

Comments may be helpful to explain business decisions ("This contradicts industry standard, but we decided to accept the
message anyway"), historical learnings ("Cannot be deleted to maintain backwards compatibility"), or explain
uncertainty ("Checking data consistency because imported data might be inconsistent here").

# Conclusion

The book provides a nice overview over code smells and how to fix them. It was quite fun to explore the code smells,
think about how to display them in code, and also keeping an eye on my work code base spotting both code smells and nice
refactorings.

Besides all the hard skill learnings, the idea of refactoring line by line, with passing tests, allways ensuring no
external behavior is changed is the most enlightening skill I took from this book. It is a challenge, and I am not
saying that I will never again look at smelly code and just creating a new file rewriting it from scratch, I now know I
always have the option to only change it in a save and sane way, bit by bit (and might request the same for code I
review).

Happy Coding :)
