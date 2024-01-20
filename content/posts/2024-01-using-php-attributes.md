---
title: "Dive into PHP Attributes"

date: 2024-01-12T14:20:44+02:00

draft: false

description: PHP attributes are a great addition to the language. But how are they used, can I use them, and what are Use Cases?

tags: [ "Agile", "Team Communication" ]
---

{{< lead >}}
PHP attributes are a great addition to the language. But how are they used, can I use them, and what are Use Cases?
{{< /lead >}}

## What Attributes can do

Attributes are one of the greatly expected features of PHP 8.0. They are a way to add metadata to classes, methods, or
properties/ constants. The feature itself is no new idea PHP came up, but many other languages already utilize
Attributes or Annotations (as many languages call them) - and therfore we can learn from Frameworks like Spring to learn
how to use Attributes [^spring].

[^spring]: [Spring Framework - Annotations](https://www.javatpoint.com/spring-boot-annotations)

{{< alert "circle-info" >}}
Attributes are awesome! But as you will se in the implementation examples, they are a bit of magic. I personally
consider them less "magic" than Laravel's partially visible Providers, or Symfonie's yaml config files.
{{</alert >}}

### Implementation Example of Attributes as Listener Config

Depending on the Framework there are implementations for Listener Wiring, Symfony already switched the `.yaml` config
for Attributes. The following example is a simplified version of this Idea.

Dev-User Perspective first, what should be achieved? Possible Solutions to add the attribute to the class and
implementing a `function on(EventInterface $event): void` method. In that case the Attribute should target the class.

```php
#[ListensTo(UserCreated::class)]
readonly class UserListener
{
    public function on(EventInterface $event) { ... }
}
```

But we can also target the method, which would be a bit more verbose, but impractical if there are multiple events that
require actions by multiple methods.

```php
readonly class UserListener implements EventListenerInterface
{
    #[ListensTo(UserCreated::class)]
    public function onUserCreated(UserCreated $event) { ... }
}
```

The Attribute itself is implemented as class. Here the implementation for the Listener on the class. As it should be
possible to register more than one event on the listener, the Attribute is marked as `IS_REPEATABLE`.

```php
#[Attribute(Attribute::TARGET_CLASS| Attribute::IS_REPEATABLE)] readonly class ListensTo
{
    public function __construct(public string $event) {}
}
```

A list of possible targets are listed in the Attribute class [^attribute]:

* `TARGET_CLASS = 1` Marks that attribute declaration is allowed only in classes
* `TARGET_FUNCTION = 2` Marks that attribute declaration is allowed only in functions
* `TARGET_METHOD = 4` Marks that attribute declaration is allowed only in class methods
* `TARGET_PROPERTY = 8` Marks that attribute declaration is allowed only in class properties
* `TARGET_CLASS_CONSTANT = 16` Marks that attribute declaration is allowed only in class constants
* `TARGET_PARAMETER = 32` Marks that attribute declaration is allowed only in function or method parameters
* `TARGET_ALL = 63` Marks that attribute declaration is allowed anywhere
* `IS_REPEATABLE = 64` Notes that an attribute declaration in the same place is allowed multiple times

[^attribute]: [Very good Article about Attributes](https://php.watch/articles/php-attributes)

To read out the attributes, the Reflection API is used. In this case a Method is called during the container build.

```php
public function register(EventListenerInterface $listener): void
{
    $reflection = new ReflectionClass($listener);
    foreach ($reflection->getAttributes(ListensTo::class) as $attribute) {
        /** @var ListensTo $listensTo */
        $listensTo = $attribute->newInstance();
        $this->listeners[$listensTo->event][] = $listener;
    }
}
```

This was the point where I was amazed how easy this was! Of cause using the Reflection API always feels like performing
black magic, but in this example I find it way more readable than some configs.

### Replacing configs with Attributes

* Symfony requires configs for Dependency Injection, which could be replaced by a Spring inspired [#Autowired]
  Attribute.
* The mentioned Listener Wiring could be replaced by a [#ListensTo] Attribute.
* The [#Route] Attribute could replace the `routes.yaml` config file (or the `routes/api.php` in Laravel). There are
  already some implementations for this [^route-attribute].
  [^route-attribute]: [Route Attributes for Laravel](https://stitcher.io/blog/route-attributes)
* The [#Handels] Attribute could map Commands to CommandHandlers

### Validation

Validation using Attributes comes in so easy, readable, and minimalistic.
Imagine a Request could look like this:

```php
class UserCreateRequest {
  #[Required()]
  public readonly string $name = null;

  #[Min(1)]
  #[Max(10)]
  public readonly string $numberBetweenOneAndTen = 0;

  #[Pattern("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$")]
  public readonly ?string $ipAddress = null;
  
  ...
}
```

### Other use cases

* [#Example] Attribute to give an example, but maybe also to generate mini fixture
* [#Dataset] Provide a dataset for a test
* [#SupressWarnings] could replace the `phpstan-ignore` comments

## Conclusion

Attributes are a great addition to PHP. I am looking forward to see how they will be used in the future, and hope they
will replace some configs, classes, and make code more readable.

Happy Coding :) 
