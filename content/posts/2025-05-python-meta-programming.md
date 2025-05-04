---
title: "Meta Programming in Python"

date: 2025-05-03T10:20:44+02:00

draft: false

description: Metaprogramming is a powerful tool in Python, but it should be used with caution. In this post, we will explore what Python can do with itself, and how it is used in frameworks.

tags: [ "Python", "Development" ]
---

{{< lead >}}
Metaprogramming is a powerful tool in Python, but it should be used with caution. In this post, we will explore what
Python can do with itself, and how it is used in frameworks.
{{< /lead >}}

## Meta Programming

As the name suggests, Metaprogramming means writing programs that interact with the code itself.

The most simple example is checking the type of a variable, so gathering information about the code at runtime, and
making decisions based of that. Especially when coding within a framework, there are many contact points with meta
programming, for example when using decorators that "magically" transform a function into a job, inheriting from a class
that "magically" transforms a class into a model that triggers migrations on change. Metaprogramming is a powerful tool,
especially when writing code that is used by other developers consuming their code, like a framework.

### When to use it?

Metaprogramming should be used with caution. It is often used to hide complexity from the developer who just wants to
use the magic. This hiding is what makes many frameworks so magically working without the need to understand the
internal processes. But on the other hand, it makes it really hard to go through the code, following the flow of data,
because it is hidden - objects or classes are touched, manipulated, or read at places where it is not expected.

It sometimes can be tempting to implement a program using metaprogramming, but it is often better to use simpler,
understandable code to ensure the next developer can continue.

{{< alert >}}
Metaprogramming is a powerful hammer in a world with only very few nails. Use it with caution, if you are not developing
a framework, and your code aims to be maintainable, most likely you should use a different tool.
{{< /alert >}}

![Corgi warnging for dark magic](/images/2025-05-dark-magic.png)

## Metaprogramming in Python

This post is strongly inspired by the Meta Programming Course by Trey Hunner [^Hunner].

### Introspection: I want to know about the technical properties of an object

Python provides many built-in functions to introspect objects like does it have a certain attribute `hasattr`, what is
the type of the object `type`, what is the name of the class `__name__`, or is it callable `callable`. I would like to
highlight Annotated Properties, because they not only enable reading meta information about a property, but also a way
to add meta information to a class property.

An easy, somewhat common form of Metaprogramming, given meta information about a class property, that are stored
there using the Annotated Property. Using the `__annotations__` attribute of a class, you can get the annotation of a
class, and build therefore code based on how the other code is written or types.

```python
from typing import Annotated, get_args


class Magic:
    def __init__(self, is_dark: bool = False):
        self.is_dark = is_dark


class Wizard:
    wand: Annotated[str, "magic", Magic(True)] = "Magic Staff"


merlina = Wizard()
annotation = merlina.__annotations__.get("wand", None)

print(annotation)

if any(isinstance(magic, Magic) for magic in get_args(annotation)):
    print("Merlina can use magic!")
```

```terminaloutput
typing.Annotated[str, 'magic', <__main__.Magic object at 0x1006bffd0>]
Merlina can use magic!
```

### Decorators: I want to add functionality to a function

Decorators are meta programmatic tools that diverge from the expected flow of the code. They are used to wrap around a
function (or class). A decorator is a function that takes another function as an argument and returns a new function
that adds some kind of behaviors. [^Hunner] [^pythontips]

[^Hunner]: [Meta Programming by Trey Hunner](https://www.oreilly.com/live-events/python-metaprogramming-in-practice/0642572014596/)
[^pythontips]: [Python Decorators in Python Tips](https://book.pythontips.com/en/latest/decorators.html)

The wrapper function should be able to receive the same arguments as the original function, so it needs to hand down its
`*args, **kwargs` to the original function. It should also return the value of the original function.

```python
def make_magic(func):
    def magic_wrapper(*args, **kwargs):
        print("✨Magic started ✨")
        value = func(*args, **kwargs)
        print("✨Magic ended ✨")
        return value

    return magic_wrapper


def abracadabra(input: str) -> None:
    print("Abracadabra " + input + "!")


abracadabra = make_magic(abracadabra)
abracadabra("Hoc")
```

```terminaloutput
✨Magic started ✨
Abracadabra Hoc!
✨Magic ended ✨
```

Now the original `abracadabra` function is overwritten by the `magic_wrapper` function which contains the original
function. Python provides a syntactic sugar to make this easier, using the `@` symbol to decorate the function instead
of `abracadabra = make_magic(abracadabra)`.

```python
@make_magic
def abracadabra(input: str) -> None:
    print("Abracadabra " + input + "!")


abracadabra("Hic")
```

```terminaloutput
✨Magic started ✨
Abracadabra Hic!
✨Magic ended ✨
```

Decorators can be very versatile! They can be used to add functionality to a function, allow some meta information added
to the function, add a parameter, or (e.g. a decorator to skip a test) even to replace the function itself.

Mind the scopes, variables defined in the decorator are not available in the wrapper function, but Python allows adding
variables to

```python
def make_magic(func):
    def magic_wrapper(*args, **kwargs):
        print("✨Magic started ✨")
        value = func(*args, **kwargs)
        magic_wrapper.mana -= len(str(args) + str(kwargs)) - 6
        print("✨Magic ended ✨Mana left: " + str(magic_wrapper.mana))
        return value

    # Mind the scopes! A variable defined in the decorator is not available in the wrapper function.
    # Also avoid adding variables to the wrapped function (func) itself to avoid unexpected side effects. 
    magic_wrapper.mana = 100
    return magic_wrapper


@make_magic
def abracadabra(input: str) -> None:
    """  A magic function that prints a message. """
    print("Abracadabra " + input + "!")


print(abracadabra("Mundus"))
print(abracadabra("est"))
print(abracadabra("magia"))
```

```terminaloutput
✨Magic started ✨
Abracadabra Mundus!
✨Magic ended ✨Mana left: 93
✨Magic started ✨
Abracadabra est!
✨Magic ended ✨Mana left: 89
✨Magic started ✨
Abracadabra magia!
✨Magic ended ✨Mana left: 83
```

There is one problem with this approach: What looks like the original function is in fact a wrapper function. The
information of identity, DocStrings, etc is lost.

```python
print(help(abracadabra))
```

```terminaloutput
Help on function magic_wrapper in module __main__:

magic_wrapper(*args, **kwargs)
```

To avoid this, Python provides a `functools.wraps` decorator. This decorator is used to update the wrapper function with
all the attributes of the original function, including its name, docstring, and module. Internally it adds the original
function to the `__wrapped__` property of the wrapper function.

```python
from functools import wraps


def make_magic(func):
    @wraps(func)
    def magic_wrapper(*args, **kwargs):
        print("✨Magic started ✨")
        value = func(*args, **kwargs)
        print("✨Magic ended ✨")
        return value

    return magic_wrapper


@make_magic
def abracadabra(input: str) -> None:
    """  A magic function that prints a message. """
    print("Abracadabra " + input + "!")


print(help(abracadabra))
```

```terminaloutput
Help on function abracadabra in module __main__:

abracadabra(input: str) -> None
A magic function that prints a message.
```

{{< alert >}}
Be a nice developer and add `@wraps` to every decorator you implement. And reconsider the need for a decorator in the
first place.
{{< /alert >}}

**Decorators in Practice:** Most frameworks use decorators to add functionality to functions or classes, even many
libraries. For example Celery [^celery] uses decorators to define tasks. Well written decorators are easy to find a
project by searching for `@wraps` in the code, so feel free to find out how your project uses decorators.

[^celery]: [Celery using Decorators](https://docs.celeryq.dev/en/stable/django/first-steps-with-django.html#django-first-steps)

**Class Decorator** work the same way, but instead of a function, a class is passed to the decorator, and a class is
returned. A common used Class Decorator is `@dataclass`, which returns the same class as was passed in, but with dunder
methods added.

### Descriptors: I want to control how a class attribute is accessed or modified

Sometimes it is handy to have an attribute that is not just a simple value, but calculated based on another value, like
the radius of a circle and its area. Also it would be nice if the attribute could be set and the related value would
also update. Such a behavior can be implemented using a descriptor.

Descriptors are objects that define how attributes are accessed or modified. They are defined by a class that
implements either of the three methods `__get__`, `__set__`, or `__delete__` [^pythonDescriptors]. A descriptor that
implements only the `__get__` method is called a non-data descriptor, while a descriptor that implements more is called
a data descriptor. To understand how descriptors work, it is important to understand how Python looks up attributes.

To understand how Python looks up attributes on an object the `__dict__` attribute of the object is used. This attribute
is a dictionary that contains the properties of the object, or if used on the type of the object, the class properties.
Instance properties override class properties.

```python
class Potion:
    milliliter: int = 50
    color: str = "yellow"

    def __init__(self, color: str):
        self.color = color


invisibility_potion = Potion("magenta")
print("Instance Dict")
print(invisibility_potion.__dict__)
print("Class Dict")
print(Potion.__dict__)
```

```terminaloutput
Instance Dict
{'color': 'magenta'}
Class Dict
{'__module__': '__main__', '__annotations__': {'milliliter': <class 'int'>, 'color': <class 'str'>}, 'milliliter': 50, 'color': 'yellow', '__init__': <function Potion.__init__ at 0x105751f30>, '__dict__': <attribute '__dict__' of 'Potion' objects>, '__weakref__': <attribute '__weakref__' of 'Potion' objects>, '__doc__': None}
```

In Python the logic of attribute lookup is implemented in C for performance reasons (after all, this code will run on
every attribute access). The Code can be found in
the [CPython repository](https://github.com/python/cpython/blob/3e256b9118eded25e6aca61e3939fd4e03b87082/Objects/object.c#L1670)
in a method called `_PyObject_GenericGetAttrWithDict`. But a pure Python implementation is provided in the Python
docs[^pythonDescriptors].

[^pythonDescriptors]: [Python Descriptors](https://docs.python.org/3/howto/descriptor.html#descriptor-protocol)

```python
def object_getattribute(instance: object, attribute: str):
    """ Emulate PyObject_GenericGetAttr() in Objects/object.c """
    instances_type = type(instance)
    type_dict_at_attribute = getattr(instances_type, '__dict__', {})[attribute]

    # NonData Descriptors are defined by implementing __get__ method
    has_non_data_descriptor = hasattr(type_dict_at_attribute, '__get__')
    # Data Descriptors are NonData Descriptors that implement __set__ or __delete__ method
    has_data_descriptor = False
    if has_non_data_descriptor:
        if hasattr(type_dict_at_attribute, '__set__') or hasattr(type_dict_at_attribute, '__delete__'):
            has_data_descriptor = True

    # if there is a Data Descriptor, return the result of its __get__ method
    if has_data_descriptor:
        return type_dict_at_attribute.__get__(instance, instances_type)

    # If the attribute is defined in the instance's __dict__, return it
    if attribute in instance.__dict__:
        return instance.__dict__[attribute]

    # If there is a non-data descriptor, return the result of its __get__ method
    if has_non_data_descriptor:
        return type_dict_at_attribute.__get__(instance, instances_type)

    # If the attribute is defined in the class's __dict__,
    if attribute in instances_type.__dict__:
        return instances_type.__dict__[attribute]
    raise AttributeError(attribute)
```

**Python Descriptors in Practice** Descriptors are commonly used in Python to implement properties using the decorator
`@property`, which disguises the setter and getter methods into methods of the class.

```python
class Potion(object):
    milliliters = 50
    usage_size = 10

    def use(self) -> None:
        if self.milliliters > 0:
            self.milliliters -= self.usage_size
        else:
            raise ValueError("Potion is empty")

    @property
    def usages(self) -> int:
        return int(self.milliliters // self.usage_size)

    @usages.setter
    def usages(self, value: int) -> None:
        self.milliliters = value * self.usage_size


invisibility_potion = Potion()
print(f"I made 🧪 Potion with {invisibility_potion.milliliters}ml")
invisibility_potion.use()
print(f"After using the potion, I have {invisibility_potion.milliliters}ml left")
invisibility_potion.usages = 20
print(f"After refilling the potion, I have {invisibility_potion.milliliters}ml left")
```

```terminaloutput
I made 🧪 Potion with 50ml
After using the potion, I have 40ml left
After refilling the potion, I have 200ml left
```

An example of a data descriptor that abstracts logic away would be Djangos `ForeignKey` [^django]. While the developer
who wants to use the framework does not need to know how the `ForeignKey` works, they can use it like property, but
Django uses the descriptor to implement the retrival or storage of the related object in the database.

[^django]: [Django ForeignKeys as Descriptors](https://github.com/django/django/blob/main/django/db/models/fields/related_descriptors.py)

### MetaClasses: I want to create a new Type and control how classes are created

All Types in Python are(Meta)Classes that inherit from `type`, but all instances of a Type are Classes.

```python
class Wizard:
    pass


print("A wizard instance is: " + str(type(Wizard())))
print("Wizard class is a: " + str(type(Wizard)))
```

```terminaloutput
A wizard instance is: <class '__main__.Wizard'>
Wizard class is a: <class 'type'>
```

Having a MeterClass allows to control how classes are created, for example if they are Singletons [^metaSingeltons].
The usage of methods like `__new__` and `__init__` can be overwritten to control the creation of many classes.

[^metaSingeltons]: [Meta Classes as Singletons](https://python-course.eu/oop/metaclasses.php)

```python
class OrderOfWizards(type):
    """
    The Maiar of the Order of Wizards may be found in many places,
    but wherever one class of Maiar is found, it will be always the same instance.
    """
    wizards: dict[str, "OrderOfWizards"] = {}

    def __call__(wizard_class, *args, **kwargs):
        if str(wizard_class) not in wizard_class.wizards:
            wizard_class.wizards[str(wizard_class)] = super(OrderOfWizards, wizard_class).__call__(*args, **kwargs)
        return wizard_class.wizards[str(wizard_class)]


class Gandalf(metaclass=OrderOfWizards):
    color: str = "grey"


gandalf = Gandalf()
print(f"There he is, Gandalf the {gandalf.color}!")
gandalf.color = "white"
gandalf = Gandalf()
print(f"There he is, Gandalf the {gandalf.color}!")
```

```terminaloutput
There he is, Gandalf the grey!
There he is, Gandalf the white!
```

**Metaclasses in practice:** Django uses metaclasses to control models. The `Model` class that is extended by all models
has the BaseModel as MetaClass[^djangoModels]. This class is used to handle Model metadata, like the database table or
the migration status.

[^djangoModels]: [Django Models usage of Meta Classes](https://github.com/django/django/blob/main/django/db/models/base.py)

## Conclusion

All these tools are powerful, and looking how frameworks use them to provide a magically smooth experience for the
developer can be inspiring. But it is important to understand, that many of these tools are not easy to understand
without knowing the underlying mechanics. They are hard to debug, it's not easy to follow the flow of code, and when not
implemented correctly, they can lead to unexpected behavior.

If you think about using them, ask yourself if you just want to use the magic like a dark magic apprentice, or if you
explicitly want to hide complexity from the developer who will use your code.

On this very post, Happy Understanding :)
