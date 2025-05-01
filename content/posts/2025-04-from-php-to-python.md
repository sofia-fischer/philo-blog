---
title: "Learning a new language - from PHP to Python"

date: 2025-04-20T10:20:44+02:00

draft: false

description: Learning a new language is like learning a new way of thinking. It is not just about the syntax, but also about the
  patterns, the culture.

tags: [ "Python", "Development" ]
---

{{< lead >}}
Learning a new language is like learning a new way of thinking. It is not just about the syntax, but also about the
patterns, the culture.
{{< /lead >}}

## Changing Language

I have been coding in PHP since 2018 professionally, and after 6 years I am now switching to Python.

Coding in one language does mean more than knowing that syntax. Mastering a language meaning understanding pitfalls, how
some parts of the language work internally, what tools the language provides for meta programming; it includes knowing
the best practices, the accepted and unacceptable hacks, which style will be understood by the next developer and
what is too "we don't to that in our language". Examples of what I mean by that are excessive use of
pass-by-references in PHP or "Panic-driven" GoLang Code.

The language influences the architecture, the usage of patterns, and the tools - and often underestimated: the projects.
Maybe there is a PHP Developer out there who never had to implement a Web Shop, but I guess they are as rare as Python
Developers who never implemented a Data Science project. Different languages have different ecosystems, different
specializations. Python has a strong Data Science and Machine Learning community, historically because of its
beginner-friendliness, to now owning established libraries for data manipulation and interpretation. While PHP still
dominates the web, historically started as template engine, growing whatever Wordpress is now, and powering many old and
new web projects.

![Corgi meeting a snake](/images/2025-04-python.png)

## The different levels of learning a new language

First, how do you run the code, aka how do you get the "Hello World" on the screen? Is the common practice using a
docker container or a virtualenv to control language version? How do you install packages? How do you run the tests?
Which frameworks are common?

Supported by a nice coding AI, its about learning the syntax, the data structures, the libraries, and the tools. What
can you do with the langauge, where are limits and the pit falls? How are tests written and how does debugging work?

At some point, it is unavoidable to include the human factor. How doe the developers of the language think, what are the
common practices and patterns? How do they uses the given tools?

{{< alert "circle-info" >}}
**This is no tutorial**: This are fractions of what I learned that I found interesting and wanted to share.
{{< /alert >}}

### Python Data Structures

Typing: Typing always conveys intention, and in Python this can be done even more verbose than in PHP. Python provides
Generators, supports Union types, specialised Types like Literals, and Annotated Types.
Python Datastructures are so diverse and can convey so many intentions:  Is the content ordered like a list? May it not
contain duplicates like a set? Is it immutable like a tuple? Is it handled lazy like a generator? Does it have defaults
like a DefaultDict? Is it designed to be stored in a database like a flag? [^robustPython]

[^robustPython]: [Robust Python](https://www.oreilly.com/library/view/robust-python/9781098100650/)

|            | Description                                                                                            | Mutable | Ordered | Duplicates |
|------------|--------------------------------------------------------------------------------------------------------|---------|---------|------------|
| List       | A collection that is meant to be iterated over or indexed, `[1, "two"]`                                | ✅       | ✅       | ✅          |
| Range      | Immutable sequence of numbers and is commonly used for looping `list(range(0, 10, 3)) == [0, 3, 6, 9]` | ❌       | ✅       | ✅          |
| Tuple      | Immutable collection, e.g. an extracted database row `(4, "Ball Python", "#EA387D")`                   | ❌       | ✅       | ✅          |
| Set        | A collection free of duplicates, containing only immutable objects `{"#EA387D", "#003F23"}`            | ✅       | ❌       | ❌          |
| FrozenSet  | Immutable Sets `frozenset("Frozen Snakey")`                                                            | ❌       | ❌       | ❌          |
| Dictionary | A key value structure, possibly nested like a json `{"animal": "Ball Python", "name": "Snickers"}`     | ✅       | ✅       | (🔑❌)      | |

Table infos from [^PythonDocs]

[^PythonDocs]: [Python Docs](https://docs.python.org/3/library/stdtypes.html)

Lists are the most common data structure as they support many operations that also make them easy to use stacks or
queues. Also they support the awesome list comprehensions to create lists almost in mathematical notation.

```python
[snake for snake in snakes if snake.size > 2]
```

As mutable data structures, they also cause one of the weirdest pitfalls: Python uses pass by reference, even
on function parameter defaults. The Python compiler will go through a function parameter with the default value
`[]` and will create a pointer to a list. If the function is called multiple times, the same pointer is used,
potentially reusing a filled list. Avoid this by using `None` as default value or use immutable data structures like
tuples. [^mutableSideEffects]

[^mutableSideEffects]: [Mutable Arguments and their problems](https://www.pythonmorsels.com/mutable-default-arguments/)

### Magic Methods

In Python there are magic methods that allow you to overload operators and define what happens with the Class on
casting, or how Classes can behave like a list or a dictionary - "Dunder Methods" (because "Doubler Underscore")
Be careful with them - if it is not doubtlessly clear what the code does, the developer can not easily click on the
operator to check the behavior like with a non-magic function, eventually tracing down inheritances to find the magic
method to understand the code.

Nevertheless, they are a powerful tool to make the code more readable and to convey intention.

```python
class Snake:
    latin_name: str = "Serpens"
    size: int

    def __init__(self, size: int):
        """Constructor"""
        self.size = abs(size)

    def __str__(self) -> str:
        """String representation"""
        return ">-@" + "=" * self.size + "---"

    def __add__(self, other) -> "Snake":
        """Add two snakes together with a + operator"""
        if not isinstance(other, Snake):
            raise TypeError("Can only add Snake to Snake")
        return Snake(self.size + other.size)

    def __eq__(self, other):
        """Check if two snakes are equal"""
        if not isinstance(other, Snake):
            raise TypeError("Can only compare Snake to Snake")
        return self.size == other.size

    def __call__(self, other) -> tuple["Snake", "Snake"]:
        """Call the instance like a function"""
        half_size = int(self.size / 2)
        return Snake(half_size), Snake(half_size)

    def __iter__(self):
        """Iterate over the snake like it is a list"""
        for segment in range(self.size):
            yield Snake(1)

    def __getitem__(self, index: int) -> "Snake":
        """Get a segment of the snake like it is a dictionary"""
        if index < 0 or index >= self.size:
            raise IndexError("Index out of range")
        return Snake(1)
```

These are only a few examples of the magic methods that Python provides. Much more are listed here by Trey Hunner
[^magicMethods].

[^magicMethods]: [Magic Methods in Python](https://www.pythonmorsels.com/every-dunder-method/)

### Typing

Python allows much more Typing options than PHP, while both support Type unions, None type, and casting (and magic
methods to cast), Python also has some special things.

**Type Alias** Because Python Types are somewhat classes, you can create Type Aliases.

```python
Hydra = list[Snake]
snakes: Hydra = [Snake(1), Snake(2), Snake(3)]
```

**Type Hinted Functions** Python supports Typed Functions, which I feel like a blessing, as it seems to be "Pythonic" to
hand over functions as parameters to make functions work in different use cases.

```python
def feed(snake: Snake, food_count: int) -> Snake:
    snake.size += 1
    return snake


def sleep(snake: Snake, days: int) -> Snake:
    snake.size -= 1
    return snake


snake_care_methods: list[Callable[[Snake, int], Snake]] = [feed, sleep]
```

**Generics** A feature PHP misses, Generics allow to define that a Type will stay consistent, for example that a
function that sorts a list of one type will also return a list of the same type, independent of the type.

**Annotated** Python even allows adding more meta information to a Type, although this is often not checked by the type
checker, but it can be used with `ValueRange` or other self implemented classes, to give contexts like "Is this
Percentage a float between 0 and 100, or 0 and 1?", or "Does country refer to a country code or a country name?".

```python
from typing import Annotated


class Snake:
    size: Annotated[int, "Should be nice",] = 3


severus = Snake()
print(severus.__annotations__)

>> > {'size': typing.Annotated[int, 'Should be nice']}
```

## Pythonic Culture

Code should be natural to interact with, which also means that if follows cultural conventions (which starts with
naming, but extends up to patterns). It means that it uses magic with caution, and is braced for misuse - which is
easiest if the developer is well-informed about how the language can be misused or what magic is common
knowledge. [^robustPython]

In Python there is so much possible. There are many conventions on how to solve common things, and while the fun part
about switching languages is sometimes challenging those conventions, there is also a lot to learn.
When to use dataclasses, when Attr, and when Pydentic [^dataclass]? Why to Python developers so rarely use Dependency
Injection, and how else do I solve Inverting Control Problems [^ControlInversion]? When to use Flags? Why is nobody
using match case?

[^dataclass]: [Dataclass vs Attrs vs Pydantic](https://jackmckew.dev/dataclasses-vs-attrs-vs-pydantic.html)
[^ControlInversion]: [Dependency Injection in Python](https://seddonym.me/2019/08/03/ioc-techniques/)

What Pythonic is and what not is still something I am learning, but while many learnings in a new language can be
discovered in self-study; this is something that requires working in one project with other experienced developers.

## Conclusion: Stay Curious

Looking back, it wasn't a big step, but in between it felt like one. In between, I can contribute with my
experiences of a different language and its patterns to architecture decisions, while at the same time asking questions
why my for loop doesn't work.

I am looking forward to share my experiences with learning Python.

Happy coding :) 

