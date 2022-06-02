---
title: "Manager and Driver Pattern - pattern, implementation, and usage"

date: 2022-05-22T08:13:44+02:00

draft: false

description: "Driver-based Development is a coding pattern that is common in the Laravel world and used in multiple instances in the
framework. It's important to understand how Drivers and Managers work to understand how the framework solves some
problems, but it's also a nice pattern to keep in mind for example to write tests that usually work with third-party
APIs"

tags: ["Development", "Software Pattern", "Laravel"]
---

{{< lead >}}

Driver-based Development is a coding pattern that is common in the Laravel world and used in multiple instances in the
framework. It's important to understand how Drivers and Managers work to understand how the framework solves some
problems, but it's also a nice pattern to keep in mind for example to write tests that usually work with third-party
APIs

{{</lead >}}

## Manager and Driver Pattern (ad other Patterns)

I started the research for this post to learn more about the software patterns. After my last learning on the usage of
the Repository Pattern in [this post]({{< ref "posts/2022-05-custom-query-builder-pattern" >}}) about something similar
to the Repository Pattern. So to keep this from happening, I want to give a small overview of the patterns that crossed
my research path. This resulted in some learning, some confusion, and a somewhat understanding of the different patterns
that people associated with the Driver Pattern. Keep in mind, in the end, Software Patterns are proven concepts that
solve common problems in programming.

![Why do I care for Software Patterns?](/images/2022-05-patterns.png)

### Builder Pattern

The Builder Pattern enables the build-up of complex objects, the most common example would be the ORM Eloquent. Every
Laravel developer has used it to build the complex object representation of a SQL query. Another example are Laravel
Factories, which also use a number of methods to create a complex object in a readable way. I
recommend [this post to learn more](http://snags88.github.io/builder-pattern-in-laravel).

```php
$users = User::factory()
    ->has(Post::factory()->count(3))
    ->suspended()
    ->make();
```

### Provider Pattern

The Provider Pattern has more definitions than I expected... It can refer to the Data Provider pattern I used in Flutter
and Angular to store and hold data; it may refer to the encapsulation of methods that do different things like a plugin
or STK; or in the Laravel world Provider refer to application bootstrapping and configuration, they register routes,
singletons, or bind listeners to events. I recommend asking the person who mentioned it to explain to what they refer.

### Factory Pattern

The Factory Pattern (not Laravel Factories!) enables the creation of various types of objects on runtime. The decision
on which precise class to create is done during runtime, but usually the same in different environments. It can be
powerful if you don't know which type of object to create, e.g. if the client may decide this; or you want to have the
creation of multiple objects in one class to localise them or share functions they both need. I
recommend [this post to learn more](https://www.sitepoint.com/understanding-the-factory-method-design-pattern/)

```php
ProductFactory::build('Computer');
```

### The Driver Pattern in contrast to all of them

Different Drivers enable different implementations to perform the same tasks. The most common example is sending
messages using different services. A driver could be `sms`, one `mail`, and one `push notification`. The task is always
sending the message to the given set of users, but the implementation is different, other third-party APIs might be used
and sometimes the decision of which driver to use is done on runtime. Another example in the Laravel world is the Cache
Driver that stores your cache in `redis` or `table`, or the Database Driver that translates your Eloquent to `mySql`
or ` pgsql`.

```php
Message::channel('mail')
    ->to($user)
    ->content('Do not think about pink elephants')
    ->send();
```

Now about the different Patterns: This code utilizes the Builder Pattern to set the properties of the object step by
step, but the Driver Pattern Magic happens just in the first line which determines how the message is sent. In the
Driver class itself somewhere the implementation of the sending must be, and there I would call some Service class or
library for actually sending emails and another one for sending SMS. The Factory Pattern might look similar at first
sight as it also creates an object on runtime based on a string, but the Factory Pattern aims to instantiate Models
while the Driver Pattern aims to instantiate classes that offer defined functionalities.

## When to use a Driver Manager Solution

The most common answer to this question I found was:
> A driver-based service is the right choice when the same utility can be provided by more than one technology.
> [Source](https://inspector.dev/how-to-extend-laravel-with-driver-based-services/)

So whenever you discover a problem that might now (or in the future) be solved by multiple or changing technologies,
this pattern can make it easy and simple to switch between the technologies depending on runtime decisions, database
entries, or environment variables.

**But there is more**! I want to emphasize two other options when this pattern can be a handy tool:

**Testing and local development** can be a non-trivial task if you use third-party APIs or your own Micro Services.
During tests (and sometimes during local development) you don't care about the correctness of the technology you are
using, and maybe don't even want to trigger any outside communication. Based on your Environment (`testing` or `local`)
you can then switch to a FakerDriver that maybe can be configured in the test to simulate a long request, a wrong
answer, or just correct behavior.

**A-B Testing of Services** The first time I came in contact with this pattern, one of the reasons (besides many others)
why we went for this pattern was the easy implementation of an A-B Test of a new Recommendation System. In a situation
in which you have two technologies to do the same job, but want to compare how the users react to both of them you can
implement a Driver pattern to let different users use different technologies and compare the individual engagement rate
of features for different user groups.

## Implementation

### Folder Structure

Here is the plan: The two Driver are `FakeDriver` and `HugoDriver` (No need to search for that name, I just made it up).
To ensure the next developer who implements a Driver will implement everything we need, the `RecommenderContract`
defines which methods should be in a Driver. The `RecommenderManager` is the file in which we define which string causes
the instantiation of which Driver, and which Driver is the Default. And the `Recommender` is the Facade we will be using
in practice.

```text
Support
└─── Drivers
│   │   RecommenderContract.php
│   │   FakeDriver.php
│   │   HugoDriver.php
│
└─── Facades
│   │   Recommender.php
│
└─── Managers
    │   RecommenderManager.php
```

To now understand the implementation I would like to follow the code starting with the usage I aim for.

```php
// using default driver
Recommender::recommendationsForUser($user);

// using custom driver
Recommender::driver('hugo')->recommendationsForUser($user);
```

### Facade

To achieve this code, we first need a [Laravel Facade](https://laravel.com/docs/9.x/facades#main-content). This Facade
will call the Recommender Manager.

> In a Laravel application, a facade is a class that provides access to an object from the container.
> The machinery that makes this work is in the Facade class. Laravel's facades, and any custom facades you create,
> will extend the base Illuminate\Support\Facades\Facade class.

As so often I recommend to type-hint all methods to utilize autocompletion as well as the possibility to "click through"
your code easily.

```php
use Illuminate\Support\Facades\Facade;

/**
 * Class Recommender
 *
 * @method recommendationsForUser(array $models, ?int $userId = null)
 * @see \App\Support\Drivers\HugoDriver::recommendationsForUser()
 * @method driver(string $name)
 *
 * @see \App\Support\Managers\RecommenderManager
 */
class Recommender extends Facade
{
    protected static function getFacadeAccessor()
    {
        return RecommenderManager::class;
    }
}

```

### Manager

The Manager defines which Driver is initiated. For this extend the `Illuminate\Support\Manager`. To implement this class
you need to define the method `getDefaultDriver`. If you want a different default per environment, this would be the
place to either return a config value or an environment variable. Then you need one method per Driver you want to build.
The Illuminate Manager will guess the method name based on the string you put in (e.g. `'fake'`)
using ` $method = 'create'.Str::studly($driver).'Driver';`.

```php
use Illuminate\Support\Manager;

class RecommenderManager extends Manager
{
    public function getDefaultDriver(): string
    {
        return env('RECOMMENDER_DRIVER', 'fake');
    }

    public function createHugoDriver(): HugoDriver
    {
        return new HugoDriver();
    }

    public function createFakeDriver(): FakeDriver
    {
        return new FakeDriver();
    }
}
```

One step is missing until this is working - registering the Manager. This is done using
a [Laravel Service Provider](https://laravel.com/docs/9.x/providers). As I don't plan to use the Recommender
functionality in every request I made it a deferred Provider.

> If your provider is only registering bindings in the service container, you may choose to defer its registration until
> one of the registered bindings is actually needed. Deferring the loading of such a provider will improve the
> performance of your application, since it is not loaded from the filesystem on every request.

```php

use Illuminate\Support\ServiceProvider;
use Illuminate\Contracts\Support\DeferrableProvider;

class RecommenderServiceProvider extends ServiceProvider implements DeferrableProvider
{
    public function register(): void
    {
        $this->app->singleton(RecommenderManager::class, fn ($app) => new RecommenderManager($app));
    }

    public function provides(): array
    {
        return [RecommenderManager::class];
    }
}
```

### Driver

The Facade calls the Manager, and the Manager decides which Driver to call, now the Driver is missing implementation.
This is very straightforward. Whatever Hugo does, Hugo does it here!

```php
use Illuminate\Support\Collection;

class HugoDriver implements RecommenderContract
{
    public function recommendationsForUser(array $models, ?int $userId = null): Collection
    {
        // implement magic here
        return collect([]);
    }
}
```

### Additional

As I mentioned I use this to test my code if it utilises third-party technology. So when I write a FakeDriver I
implement additional methods, that allow me to fake different states, time delays, or other things. Sure, you can also
write tiny Unit Tests to test such behaviors, I made the best experience with feature tests and this method of faking
data during the tests.

## Happy Coding

This was my two cents on Manager and Drivers, and the way I implemented it. When I discovered the pattern I read through
this [post by Orobo](https://itnext.io/building-driver-based-components-in-laravel-5b390dc25bd9), as well
as [this on by Valerio](https://inspector.dev/how-to-extend-laravel-with-driver-based-services/).

If you spot an error, please don't hesitate on enlighten me,

Happy Coding :) 
