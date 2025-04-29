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

## The different levels of learning a new language

First, how do you run the code, aka how do you get the "Hello World" on the screen? Is the common practice using a
docker container or a virtualenv to control language version? How do you install packages? How do you run the tests?
Which frameworks are common? I am going to skip this part, like each developer trying to teach coding to a Coding
Padawan, skipping to the fun parts.

### Describing Datastructures Intentions: Typing and Magic Methods

Typing: Typing always conveys intention, and in Python this can be done even more verbose than in PHP. Python provides
Generators, supports Union types, specialised Types like Literals, and Annotated Types.
Python Datastructures are so diverse and can convey so many intentions:  Is the content ordered like a list? May it not
contain duplicates like a set? Is it immutable like a tuple? Is it handled lazy like a generator? Does it have defaults
like a DefaultDict? Is it designed to be stored in a database like a flag? [^robustPython]

[^robustPython]: [Robust Python](https://www.oreilly.com/library/view/robust-python/9781098100650/)

Magic Methods - "Dunder Methods" (because "Doubler Underscore"): In Python there are magic methods that allow you to
overload operators and define what happens with the Class on casting, or how Classes can behave like a list or a
dictionary.
Be careful with them - if it is not doubtlessly clear what the code does, the developer can not easily click on the
operator to check the behavior like with a non-magic function, eventually tracing down inheritances to find the magic
method to understand the code.
Nevertheless, they are a powerful tool to make the code more readable and to convey intention.

```python
class Snake:
    latin_name: str = "Serpens"

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

### Classes, Types, and Functions - The Power of Classes

All Types in Python are (Meta)Classes that inherit from `type`, but all instances of a Type are Classes.

```bash
>>> Snake(1)
<class 'Snake'>

>>> Snake
<class 'Snake'>

>>> type(Snake)
<class 'type'>

>>> Snake.__str__.
<class 'function'>
```

This means that Types can be defined like properties. This can be handy! But, it almost made me cry when debugging
that one property was set to a type instead of type hinted.

```python
Snake_Or_Goat = Snake | Goat
animal: Snake_Or_Goat = Snake(1)
```

One more magic method: Classes also have a `__dict__` attribute, which is a dictionary that contains the Class's
attributes and methods. These dicts are used to get attributes of a Class or Instance - and no, the two are not the
same. The dict of a Class contains the Class's attributes and methods, while the dict of an Instance contains the
Instance's attributes that can be accessed using `self`.

```bash
>>> severus = Snake(5)
>>> severus.latin_name
'Serpens'
>>> severus.size
5
>>> severus.__dict__
{'size': 5}
>>> Snake.__dict__
{'__module__': 'builtins', 'latin_name': "Serpens", '__init__': <function ...
```

If Types are MetaClasses, and Classes can be callable, what can Functions do? A lot, actually. They can be stored in an
array and iterated over, they can have attributes, wrapped by a decorator, and functions can have functions.
And if I got Trey Hunner [^blog] [^metaProgramming] correctly, Python functions are Descriptor Objects, which would mean
they are also ... Classes?

```python
def feed(snake: Snake) -> None:
    snake.size += 1


def sleep(snake: Snake) -> None:
    snake.size -= 1


caring_methods = [feed, sleep]
[caring_methods[index % 2](snake) for index, snake in [Snake(1), Snake(2), Snake(3)]]
```

[^blog]: [Python built-in functions](https://treyhunner.com/2019/05/python-builtins-worth-learning/)
[^metaProgramming]: [Meta Programming in Python](https://www.oreilly.com/live-events/python-metaprogramming-in-practice/0642572014596/)

### Pythonic Culture

Code should be natural to interact with, which also means that if follows cultural conventions (which starts with
naming, but extends up to patterns). It means that it uses magic with caution, and is braced for misuse - which is
easiest if the developer is well-informed about how the language can be misused or what magic is common
knowledge. [^robustPython]

In Python there is so much possible. There are many conventions on how to solve common things, and while the fun part
about switching languages is sometimes challenging those conventions, there is also a lot to learn.
When to use dataclasses, when Attr, and when Pydentic [^dataclass]? Why to Python developers so rarely use Dependency
Injection, and how else do I solve Inverting Control Problems [^ControlInversion]? When to use Flags? Why is nobody use
match case?

[^dataclass]: [Dataclass vs Attrs vs Pydantic](https://jackmckew.dev/dataclasses-vs-attrs-vs-pydantic.html)
[^ControlInversion]: [Dependency Injection in Python](https://seddonym.me/2019/08/03/ioc-techniques/)

## Conclusion: Stay Curious

Looking back, it wasn't a big step, but in between it felt like one. In between, I can contribute with my
experiences of a different language and its patterns to architecture decisions, while at the same time asking questions
why my for loop doesn't work.

I am looking forward to share my experiences with learning Python.

Happy coding :) 

