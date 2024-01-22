---
title: "Technical Job Interview questions 2022"

date: 2022-06-02T14:20:44+02:00

draft: false

description: "Looking for a customer is the same process compared to looking for a job. I use the usual platforms to
find companies that are looking for my tech stack and send a spontaneous application, maybe I get invited for an
interview, maybe a technical interview with dev-related questions, or sometimes a coding challenge. In this post I want
to look back on the technical questions I got asked."

tags: ["Development", "Laravel", "Developer Life"]
---

{{< lead >}} Looking for a customer is the same process compared to looking for a job. I use the usual platforms to find
companies that are looking for my tech stack and send a spontaneous application, maybe I get invited for an interview,
maybe a technical interview with dev-related questions, or sometimes a coding challenge. In this post I want to look
back on the technical questions I got asked. {{< /lead >}}

## Interview Questions I remembered

The kind of questions I want to write about are not the "describe yourself in a three minutes" or "explain your
experience" questions. I want to rethink some technical interview questions I was asked and could or could not answer at
that point in time.

![Would code for money?](/images/2022-06-code-for-money.png)

## Laravel Questions

### What Laravel Feature do you love about Laravel 9?

That question should have been easy. One of the big features are the new accessors and mutators [^accessors]. I kinda
dislike getters and setters anyway, so I don't use them. The next big feature is the usage of Enums [^enums], which I
don't use in practice because I can't use them as array keys, which might change in the future, but until that is fixed
I get quite frustrated about this little drawback to honestly state it in an interview [^enumkeys]. Every other new
feature I found very small, and the only one I am looking forward to using is the `str()` helper function which replaces
the `Str::of()`.

[^accessors]: Laravel 9 has
new [Accessors and Mutators](https://laravel.com/docs/9.x/eloquent-mutators#accessors-and-mutators)
[^enums]: Laravel 9 has new  [Enums](https://laravel.com/docs/9.x/releases#enum-casting)
[^enumkeys]: You can not use Enums as Object keys, discussed [here](https://wiki.php.net/rfc/object_keys_in_arrays)

### What Feature do you miss about Laravel?

I think Laravel uses too many provider / list files that are not easier or less magic than other implementations. The
auto-discovery of event listener [^event-discovery] is one way to replace one provider with something easier; another
feature that would get rid of the route file would the Spring (Kotlin Framework) inspired Route binding using
Annotations / Attributes [^spring].

[^event-discovery]: Laravel offers great [Auto Discovery of Events](https://laravel.com/docs/9.x/events#event-discovery)
that I prefer over EventServiceProvider
[^spring]: Spring offers a nice way for route binding using Annotations
-> [Spring Docs](https://docs.spring.io/spring-integration/docs/2.0.0.RC1/reference/html/router.html)

In PHP Annotations are often used (at least by me) to type-hint methods and properties. For example, if I define a
relation in Laravel I type-hint the corresponding relation attribute call, now I have typed `$game->rounds()` which
returns a query builder, and `$game->rounds` which returns the collection (`$game->rounds()->get()`).

```php
/**
 * @property \Illuminate\Support\Collection rounds
 * @see \App\Models\Game::rounds()
 */
class Game extends Model
{  
    public function rounds(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Round::class);
    }
...
```

But since PHP 8, Attributes are a new feature. And they are offering quite some
opportunities [^attributes] [^attributes-2]. Besides the inconvenient naming, I like the idea and can't wait for
Attributes to replace the route file [^spatie-package]. (For anyone who misses the route file for an overall overview
has never seen a big route file and does not know the `php artisan route:list` command)

[^attributes]: Some more infos
on [Attributes at wiki.php](https://wiki.php.net/rfc/attributes_v2#why_not_extending_doc_comments)
[^attributes-2]: Best in [Depth Article about Attributes](https://php.watch/articles/php-attributes)

```php
use Spatie\RouteAttributes\Attributes\Get;

class MyController
{
    #[Get('my-route')]
    public function myMethod()
    {
    }
}
```

[^spatie-package]: There is a [spatie package](https://github.com/spatie/laravel-route-attributes) which implements what
I want, I just hope it will find a way in the "Laravel way of working"

### What standard changes or libraries do you apply to every Laravel Project?

Most times I join existing projects, and my private projects are most times to test something out and therefore focused
on whatever I want to try out, and not follow my favorite Laravel styles. I will try to add something to this list, but
if you have an answer to this question, I am curious to read it.

**Clean up Laravel Sail and switch to Prostgres** Not only because it saves some (for me usually not needed) Docker
space, but because Prostgres is the better choice for a relational Database (Enums, Money Types, in-json search, (and
the Docker Image works great for M1)).

**Write a UUID Traid** Because writing `Str::uuid()` on every model creation is annoying. I use uuids to obscure the id
towards the client, but use the numeric id for relationships.

```php
trait HasUuid
{
    // fill uuid column
    protected static function booted()
    {
        static::created(fn ($model) => $model->uuid = Str::uuid());
    }

    // set route key name
    public function getRouteKeyName()
    {
        return 'uuid';
    }
}
```

### How does a request live through Laravel?

One of my favorite questions - so I spend some time digging into the Laravel Code to find out.

**Starting the Application `public/index.php`**

Laravel said `$kernel = $app->make(Kernel::class);` and there was a Kernel. Out of the box, this is
the `app/Http/Kernel.php`. In this step the Application (which holds path information, registers
Providers...) [^application] and Router (which is the class behind Route Facade) are instantiated.

[^application]: The Laravel Application corresponds to the [Service Container](https://laravel.com/docs/9.x/container)

**Handling `app/Http/Kernel.php`**
The Kernel extends `vendor/laravel/framework/src/Illuminate/Foundation/Http/Kernel.php`, and the important method call
is `handle()`. In the handle function the Kernel tries to send the Request through the Router, configure error handling,
configure logging, and detect the application environment. After this, and before the call returns the response
the `RequestHandled` Event is dispatched.

**Pipelines `app/Http/Kernel.php`**

> The Pipeline Design Pattern is a software design pattern that provides ability to execute a sequence of operations
> where data flows through a sequence of tasks or stages. [^pipelines]

[^pipelines]: Great Article about [Pipeline usage in Laravel](https://blog.toothpickapp.com/pipeline-in-laravel-2/)

Every Middleware in Laravel is a pipe the request is sent though and a small task is performed on the Request. In this
step the HTTP Session, CSRF Token, Maintenance Prevention, and whatever Middleware you added in the Kernel.

**Dispatch to Router** `vendor/laravel/framework/src/Illuminate/Routing/Router.php`

The Router matches the Route from the Routes defined in the `routes/*` files (or other places if specified), dispatches
a `RouteMatched` Event, and again uses a Pipeline to run through the Route specific Middlewares which might include
Authentication or Authorisation.

**Run route, run** `vendor/laravel/framework/src/Illuminate/Routing/ControllerDispatcher.php`

The Route matches its Controller or Callback, whatever convention was followed. Then the Controller Dispatcher tries to
satisfy the Method Dependencies [^DependencyInjection], e.g. if you injected a Repository or FormRequest. For every
Parameter (besides the Model Bindings), a Reflection Class is created and after that an Instant of that class is made.
Some magic later the FormRequestServiceProvider kicks in (what here happens is Container Magic. Laravel Container are
something interesting, something that cause itchy bugs, and something I need to dedicate learning time to understand -
so this is magic for me at the current point in time).

[^DependencyInjection]: Learn more about Dependency Injection in Controller in
the [Laravel Docs](https://laravel.com/docs/9.x/controllers#constructor-injection)

**Validation** `vendor/laravel/framework/src/Illuminate/Foundation/Providers/FormRequestServiceProvider.php`

The Validation is triggered in the `vendor/laravel/framework/src/Illuminate/Validation/ValidatesWhenResolvedTrait.php`
first checking the Authorization, followed by the Validation. If either is not specified, a default is created.

**Controller**

After the Dependency Injection of everything the Controller needs, the business code is executed, the Controller returns
e.g. a Resource.

**Wrapping into a Response** `vendor/laravel/framework/src/Illuminate/Routing/Router.php`

The Response is wrapped into a Response again in the Router - so from Code Perspective we are already on the way back.
From that point on there is not much more to write, the Response bubbles up the way it came and is returned to the
Kernel in which it is the (Symfony) Response to build Header and Body and send the information.

## PHP Questions

### What PHP 8 Feature do you like the most?

A lot! Using Laravel examples:

**Constructor Properties**, especially for Events: Method parameters can now include the declaration of public and
private properties.

```php
class PlayerJoined
{
    public function __construct(public Game $game, public Player $player)
    {
    }
}
```

**Union Types** are great for Events as well

```php
class UpdatePlayerInformation
{
    public function handle(PlayerJoined|PlayerLeft $event): void
    {
    }
}
```

**Nullsafe Operator** is just neat. `$player->user ? $player->user->name : null` = `$player?->user->name`

**Match Expression** a bit better switch statement

```php
 $score = match ($playerRole) {
    'WEREWOLF','MINION'  => $werewolfScore,
    'TANNER'             => $tannerScore,
    'WATCHER'            => 0,
    default              => $villagerScore,
};

// match(true) is the same half shady, half awesome solution as switch(true)
$score = match (true) {
    $diffFromTarget <= 5 => 10,
    $diffFromTarget <= 10 => 3,
    $diffFromTarget <= 20 => 1,
    default => 0,
};
```

## Dev Tool Questions

### Your Query is slow, how to tackle the task to improve it?

A basic, "do you know your tools?" question.

**What can cause long client-side waiting time?** Client Issues, long boot time on Laravel side, long Query time, third
Party Api calls ... The Flow Chart I would follow would like: Is it a Backend problem? Can I replicate the

**How can I debug performance?** Simulate on Dev Environment (Seeders, Feature Tests), Postman debugging, Laravel Debug
bar [^debugbar], Logging of benchmarks, Logging with third party analytics (e.g. Performance logging in Sentry)

[^debugbar]: Awesome Feature every Laravel Developer should
use [here on GitHub](https://github.com/barryvdh/laravel-debugbar)

Bonus hint if you don't use the Debugbar: Illuminate fires an `illuminate.query` Event that you can listen for (
preferably in a Service Provider).

```php
Event::listen('illuminate.query', fn($query) => var_dump($query));
```


