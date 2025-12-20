---
title: "Registry Patterns in Python"

date: 2025-12-14T10:20:44+02:00

draft: false

description: Discovering Patterns for one Problem - Different requests reach the system, and based on the properties of each request a different
  implementation should handle the request

tags: [ "Python", "Patterns", "Architecture" ]
---

{{< lead >}}
**The Problem**: Different requests reach the system, and based on the properties of each request a different
implementation should handle the request. Many patterns exist to solve this problem, each with its pros and cons. This
post explores some off then, while in between diving deep into Python's import system.
{{< /lead >}}

## Registry by Factory

The most straightforward solution is to use a Factory that returns the appropriate implementation based on the request.
Often this is the best solution, especially if there are only a few implementations to choose from, if the selection
logic is not based on one property but on complex business rules, or it is unlikely that new implementations will be
added in the future.

```python
class Collie:
    pass


class Husky:
    pass


class Labrador:
    pass


class DogFactory:
    def get_dog_for(self, request_type: str) -> Collie | Husky | Labrador:
        match request_type:
            case "Pulling":
                return Husky()
            case "Herding":
                return Collie()
            case "Service Dog":
                return Labrador()
            case _:
                return Labrador()
```

The implementation is straightforward and easy to understand - no magic involved. Whenever a new implementation is
needed, the Factory needs to be modified, violating the Open/Closed Principle.

### Testing the Factory

The most simple test is to check that the Factory returns the expected implementation for a given request.

```python
def test_dog_factory():
    assert isinstance(DogFactory().get_dog_for("Pulling"), Husky)
    assert isinstance(DogFactory().get_dog_for("Herding"), Collie)
    assert isinstance(DogFactory().get_dog_for("Service Dog"), Labrador)
```

The Factory can not be tested in an abstract way, it is barely possible to write a test that ensures that every
implementation is reachable, or that a new implementation will be added to the factory without re-implementing the
selection logic of the Factory in the test.

## Registry by config file or list

Applying the Open/Closed Principle leads to the next simplest solution: A configuration file or list that contains the
mapping. In its simplest form, this can be a dictionary in Python code, but especially in use cases in which different
environments require different mappings, an external configuration file (YAML, JSON, etc.) is a good tool.
Even further goes the idea of a database table that contains the mapping, which can be changed at runtime without a new
deployment, is nice to test, but requires seeding / other solution for local development.

```python

class BaseDog:
    pass


class Collie(BaseDog):
    pass


class Husky(BaseDog):
    pass


class Labrador(BaseDog):
    pass


DOG_CONFIG: dict[str, type[BaseDog]] = {
    "Pulling": Husky,
    "Herding": Collie,
    "Service Dog": Labrador,
}


class DogRegistry:
    def get_dog_for(self, request_type: str) -> BaseDog:
        found = DOG_CONFIG.get(request_type)
        if found:
            return found()
        else:
            return Labrador()
```

This solution is still straightforward and easy to understand. The selection logic is now separated from the mapping,
new implementations can be added without modifying the code.

### Testing the Config Registry / Test to ensure a new implementation is listed in the config

Tests can be separated into testing the selection logic and testing the configuration. Also, tests
that ensure that every implementation is reachable and that a new configuration is added correctly are possible.

```python
from magic_registry import magic  # example function at the end of this post

from config import registry
from config import dogs


def test_config_returns_husky():
    assert isinstance(registry.DogRegistry().get_dog_for("Pulling"), dogs.Husky)


def test_config_is_complete():
    """ Test to ensure that all BaseDog implementations are registered in the DOG_CONFIG """
    all_dogs_registered = set(registry.DOG_CONFIG.values())
    import config as module
    all_dogs_in_module = set(magic.autodiscover(in_module=module, of_subclass=dogs.BaseDog))
    assert all_dogs_registered == all_dogs_in_module
```

{{< alert "comment" >}}
If there is magic involved to test the completeness of the configuration, why not use magic to register the
implementations? One obvious answer to this would be, that magic in tests is far easier to maintain than magic in
business code. If the test gets too hard to debug, it can be re-written, if the test causes more headaches than it
saves devs from forgetting to add new implementations to the config, it can just be removed.

It is a question of dev-user friendliness, and depends on the registry use case.
{{< /alert >}}

## Registry by ___init_subclass___

Looking at the Python features, there is a built-in hook method called `__init_subclass__` that is invoked whenever a
subclass is ~~defined~~ imported. The corresponding PEP even provides an example of a registry
pattern [^pep_for_init_subclass]. Based on this, there is a `BaseDog` base class that registers every subclass to a
dictionary, and the `DogRegister` using that to return the appropriate implementation.

[^pep_for_init_subclass]: [PEP 487](https://peps.python.org/pep-0487/#subclass-registration)

By this solution, it is fair to assume that there will be a directory, which contains all implementations, like this:

```text
Project/
├─ init_registry/
│  ├─ __init__.py
│  ├─ dogs/
│  │  ├─ __init__.py
│  │  ├─ husky.py
│  │  ├─ common.py
|  │  └─ corgi.py
|  └─ registry.py
└─ tests/ 
...
```

```python
#  ------------- registry.py ------------- 
class BaseDog:
    def __init_subclass__(cls, request_type: str, **kwargs):
        super().__init_subclass__(**kwargs)
        DOG_REGISTRY[request_type] = cls()


DOG_REGISTRY: dict[str, BaseDog] = {}


class DogRegister:
    # import init_subclass.dogs.corgi # Import corgi to register it
    def get_dog_for(self, request_type: str) -> BaseDog:
        found = DOG_REGISTRY.get(request_type)
        if found:
            return found
        else:
            from init_subclass import dogs
            return dogs.Labrador()


#  ------------- dogs/common.py ------------- 
from init_subclass import registry


class Collie(registry.BaseDog, request_type="Herding"):
    pass


class Labrador(registry.BaseDog, request_type="Service Dog"):
    pass


#  ------------- dogs/husky.py ------------- 
from init_subclass import registry


class Husky(registry.BaseDog, request_type="Pulling"):
    pass


# -------------  dogs/corgi.py ------------- 
from init_subclass import registry


class Corgi(registry.BaseDog, request_type="Mascot"):
    pass


# -------------  dogs/__init__.py ------------- 
from . import husky, common
```

While the other implementations had the logic in one file, this one requires the developers action to look in the base
class. And then, probably many developers would need to look up what `__init_subclass__` is doing, as it is not that
commonly used, but considering the very similar example in the PEP, I would consider its readability okay.

😈 Anyway, how long would it take a dev to understand the code is not working and why?

### Import-based Registry - and what can go wrong

Based on the above example, the first test will pass, but the second test will fail:

```python
from init_subclass import registry
from init_subclass import dogs


def test_init_subclass_returns_husky():
    assert isinstance(registry.DogRegister().get_dog_for("Pulling"), dogs.husky.Husky)  # passes


def test_init_subclass_will_not_find_secret_corgi():
    assert not isinstance(registry.DogRegister().get_dog_for("Mascot"), dogs.common.Labrador)  # fails
```

The `DogRegister().get_dog_for("Mascot")` should return a `corgi.Corgi`, but it returns the default
`common.Labrador`. The reason for that is that the `corgi.Corgi` class is never imported, and therefore never registered
in the `DOG_REGISTRY`. Which is especially tricky to test, because if there was a test implemented to test the
`corgy.py`. It would import the `corgi.Corgi` class and would also make the above test pass.

Python has one dictionary called `sys.modules` that contains all imported modules. Looking into that dictionary during a
debugging session shows that only the `husky` and `common` modules are imported, but not the `corgi` module. Importing
the `corgi` module during the debugging session registers the `corgi.Corgi` class, and then the test would pass.

```bash
# Importing sys
>>> (Pdb) import sys
# sys.modules is a dict of all imported modules, looking for Husky module
>>> (Pdb) sys.modules['init_subclass.dogs.husky']
<module 'init_subclass.dogs.husky' from '/Users/sofia/dev/PythonProject/src/init_subclass/dogs/husky.py'>
# Looking for Corgi module, but failing
>>> (Pdb) sys.modules['init_subclass.dogs.corgi']
*** KeyError: 'init_subclass.dogs.corgi'
# Importing the Corgi module
>>> (Pdb) from init_subclass.dogs import corgi
# Now the Corgi module is in sys.modules
>>> (Pdb) sys.modules['init_subclass.dogs.corgi']
<module 'init_subclass.dogs.corgi' from '/Users/sofia/dev/PythonProject/src/init_subclass/dogs/corgi.py'>
# And the Corgi module used points to the same via sys.modules
>>>(Pdb) dogs.corgi
<module 'init_subclass.dogs.corgi' from '/Users/sofia/dev/PythonProject/src/init_subclass/dogs/corgi.py'>
```

### Side Quest: Understanding Python imports

The import statement in python creates a module object, calling its module body, and by this defining a `__name__` as
the key, and `__file__` as the file path value in `sys.modules`. If the module is already in `sys.modules`, the existing
module object is used instead, which saves time.

The module in which the execution of a python project starts has `__main__` both as `__name__` and key in `sys.modules`.
Modules may check if they are run as `__main__` by checking `if __name__ == "__main__":`. For example Django is doing
that in its `manage.py` file to set up the project settings and import Django.[^django_manage]

[^django_manage]: [Django main entry](https://github.com/django/django/blob/4702b36120ea4c736d3f6b5595496f96e0021e46/django/conf/project_template/manage.py-tpl)

The imported Django module is actually a package. A package is a module that contains other modules, and is identified
by the presence of an `__init__.py` file in the directory, which is its module body .
When a package is imported, the module body in the `__init__.py` file will be executed, importing all sub-modules listed
in it. If a sub-module is not listed there, it is not imported.

This also explains why circular imports raise an exception, as the module body execution and the registration in
`sys.modules` is suspended while waiting for the imports inside the module body to finish. If the first module is
eventually imported inside its own body, the module is not yet in `sys.modules`, and would start
an infinit loop, if not excepted before. [^DjangoNutshell]

Every module uses a `__dict__` attribute as its namespace, which is a dictionary-like object that maps its attributes
to their values. Any class or attribute defined in the module body is added to this namespace, which means under the
hood that `my_module.my_class` is (somewhat) equivalent to `my_module.__dict__['my_class']`. Therefore, for very
attribute, for example a class defined in the module body, Python creates an object by calling its Metaclass (usually
`type.__new__`) to create the class object, It calls the `__set_name__` method, `super()`, in which `__init_subclass__`
of the base class is called. The fully initialized class object is then bound to the namespace that the module body is
executed in. [^PythonDataModel]

[^DjangoNutshell]: ["Python in a Nutshell" by Alex Martelli](https://learning.oreilly.com/library/view/python-in-a/9781098113544)
[^PythonDataModel]: [The Python Data Model](https://docs.python.org/3/reference/datamodel.html#creating-the-class-object)

**Manipulating sys.modules** is also possible (maybe not the best solution). In theory, deleting the module from
`sys.modules` will ensure that the tests of import-based registries work deterministically, even if other tests import
some implementations.

```python
import sys

module_identifier = "init_subclass.dogs"
modules_to_delete = [name for name in sys.modules if name.startswith(module_identifier)]
for name in modules_to_delete:
    del sys.modules[name]
```

## Registry by decorator

Another way to register implementations is to use a decorator. It looks a bit more modern that `__init_subclass__`, but
it has the same problem: If the module containing the implementation is not imported, the implementation is not
registered, as the decorators are evaluated also on creation of the class type.
I wrote a [post about decorators]({{< ref "posts/2025-05-python-meta-programming" >}}) before, so I will not go into
detail here.

```python
def register_dog(request_type: str):
    def decorator(cls):
        DOG_REGISTRY[request_type] = cls
        return cls

    return decorator


DOG_REGISTRY: dict[str, type] = {}


@register_dog(request_type="Herding")
class Collie:
    pass


@register_dog(request_type="Pulling")
class Husky:
    pass


@register_dog(request_type="Service Dog")
class Labrador:
    pass


class DogRegister:
    def get_dog_for(self, request_type: str) -> Husky | Labrador | Collie:
        found = DOG_REGISTRY.get(request_type)
        if found:
            return found()
        else:
            return Labrador()
```

## Registry by `pkgutil.iter_modules`

If python has a way to iterate through all sub-modules of a given module, and registers all attributes including their
types, it is possible to implement a registry that imports all modules in a given package, and registers all.

Frameworks often utilize similar mechanisms to auto-discover modules or classes to register them automatically, and
provide _magically working experience_ for the framework user. Examples of this are in Django
`django.utils.module_loading.autodiscover_modules` which auto-discovers modules named a certain way (e.g., `admin.py`);
that can be assumed are imported. This is utilized in Django's admin interface to auto-register models for the admin
interface. Another example, in which Django is not expecting a certain module name, is loading all migration
files [^django_migrations].

[^django_migrations]: [Django discovering Migrations](https://github.com/django/django/blob/0174a85770356fd12e4c8daa42a4f1c752ae00e6/django/db/migrations/loader.py#L112-L116)

{{< alert "comment" >}}
This implementation is heavily inspired by (/shamelessly copied from) [Markus Holtermann](https://github.com/markush).
Big thanks for the inspiration for this blog post!
{{< /alert >}}

This `discover_classes()` function uses the same `pkgutil` to iterate through all sub-modules of a given module,
collecting all python files even if only a subset is listed in the `__init__.py` file. It returns
`pkgutil.ModuleInfo(module_finder, name, ispkg)`, which is the mentioned module object.
Its `name` can be used to import the sub-module with `importlib.import_module`; and `ispkg` can be used to check if the
sub-module is a package itself, in which case the function is called recursively.
Then, `inspect.getmembers` is used to get all members of the sub-module, filtering for classes that are subclasses of
the provided Dog base class.

```python
# ------------- registry.py -------------
import importlib
import inspect
import pkgutil
from collections.abc import Generator
from types import ModuleType


class BaseDog:
    request_type: str


class DogRegister:
    _registry: dict[str, type] = {}

    def register_dogs(self):
        import iter_modules.dogs as module
        for dog in self.discover_classes(in_module=module, of_subclass=BaseDog):
            assert isinstance(dog, type(BaseDog))
            self._registry[dog().request_type] = dog

    def get_dog_for(self, request_type: str) -> BaseDog:
        found = self._registry.get(request_type)
        if found:
            return found()
        else:
            from iter_modules import dogs
            return dogs.common.Labrador()

    def discover_classes(self, in_module: ModuleType, of_subclass: type) -> Generator[type]:
        for sub_module_info in pkgutil.iter_modules(in_module.__path__):
            # import sub-module
            sub_module = importlib.import_module(f"{in_module.__name__}.{sub_module_info.name}")
            # get classes matching Base
            for name, obj in inspect.getmembers(sub_module):
                # check if it's a class and subclass of Base (and not Base itself)
                if inspect.isclass(obj) and issubclass(obj, of_subclass) and obj is not of_subclass:
                    yield obj
            if sub_module_info.ispkg:
                # recurse into sub-package
                yield from self.discover_classes(in_module=sub_module, of_subclass=of_subclass)


# ------------- dogs/any file, any __init__.py content-------------
from iter_modules import registry


class Collie(registry.BaseDog):
    request_type = "Herding"


class Labrador(registry.BaseDog):
    request_type = "Service Dog"


class Husky(registry.BaseDog):
    request_type = "Pulling"
``` 


### Testing the `pkgutil` Registry

Similar to the config-based registry, the selection logic and the completeness of the registry can be tested separately.

```python
from iter_modules import registry
from iter_modules import dogs


def test_init_subclass_returns_husky():
    dog_registry = registry.DogRegister()
    dog_registry.register_dogs()
    assert isinstance(dog_registry.get_dog_for("Pulling"), dogs.husky.Husky)
```

**When to trigger registration?** This solution is not triggered automatically on import by anything, and only uses the
iteration over modules to ensure all are imported. So, when to call the `register_dogs()` function?
One option is to utilize framework hooks like Django's AppConfig `ready()` method [^django_appconfig], or implement
similar hooks to control when the registration should happen.

[^django_appconfig]: [Django AppConfig ready()](https://docs.djangoproject.com/en/5.2/ref/applications/#django.apps.AppConfig.ready)

## Conclusion

The line between _magically working dev experience_ and _hard to debug code_ is thin. Debugging import-related issues
inspired me to write this

post, and dive deep to understand what patterns exists, and how Python imports work under the
hood. Depending on the use case, the next developer could be spared such debugging sessions by choosing a simpler
pattern, but on the other hand there are use cases in which the magic is worth it, not only for framework development.

Happy coding :)
