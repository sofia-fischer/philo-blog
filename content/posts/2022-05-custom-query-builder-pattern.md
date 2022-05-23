---
title: "Model Specific Query Builder - an Alternative to Scopes"

date: 2022-05-14T08:20:44+02:00

draft: false

description: "Scopes are nice, but by extending the Eloquent Builder for a Model enables you to add custom,
model-specific methods that are often used or should have a central definition"

tags: ["Development", "Software Pattern", "Laravel"]
---

{{< lead >}} Scopes are nice, but by extending the Eloquent Builder for a Model enables you to add custom,
model-specific methods that are often used or should have a central definition {{</lead >}}

## Scopes are great, but ...

Local scopes allow you to define common sets of query constraints that you may easily re-use throughout your
application; read more in [the Laravel Docs](https://laravel.com/docs/9.x/eloquent#local-scopes). Also, if you want to
have a definition of a scope in one central place to maybe come back and change in at one place, instead of everywhere -
a common example in practise is an `activeUser` scope (email confirmed? password not older than one year? ... ).

Scopes are great, but have two major drawbacks from my point of view: #1 no autocompletion / no "jump in your code by
clicking" on it, no type hinting. This is because drawback #2 they are executed by Laravel magics. The Framework checks
if the method you are trying to call is defined in `scope<yourMethodNameInCamelCase>` in the model and uses it then.

## About Patterns

Laravel Scopes are build utilizing the **Builder Pattern**, which enables the build-up of complex object (in this case
the object representation of a SQL Query) step by step using methods to change the query bit by bit. Now, scopes are
also following the pattern but in use cases in which a set of queries if performed often, they make the code more
readable and maintainable.[^driver-manager-pattern]

[^driver-manager-pattern]: In [this post]({{< ref "posts/2022-05-driver-manager-pattern" >}}) I write more about
patterns

### Repository Pattern

One pattern is partially similar, the Repository Pattern was the closest I could find. Most times the Repository handles
create, delete, and index methods, while this post focuses on index / query methods only. The only I could not find a
specific Pattern I could match the custom query builder with, but

The Repository is an abstraction Layer of Data, from this abstraction Layer the data may be retrieved using function
like `Post::getAll()` or in the case of Eloquent `Post::all()`. Most implementations of the Repository pattern I found
are doing the above step of overwriting Eloquent methods with their own `getAll` method. But instead of overwriting the
Eloquent methods, why not just extend them? [^repository-sources]

[^repository-sources]: In my personal point of view the only reason to completely implement this pattern is to generate
everything starting from routes, to controller, and resources based on an openApi file or so,
but [here is an example](https://laravelarticle.com/repository-design-pattern-in-laravel)

## Writing a Custom Builder that Extends the Eloquent Builder

The Builder that Laravel uses behind every `::query()` is the `Illuminate\Database\Eloquent\Builder`. A class that
extends this Builder for one Model offers the opportunity to add custom methods to the Builder.

Compared to Scopes I want to highlight, that neither the Scope Prefix is needed, nor the $query parameter. Additionally,
this utilises the fully typed / auto-completion feature I value so much [^other-sources].

[^other-sources]: When I looked through the web, the only blog articles I could find, which did implement this pattern
where [this one by Martin Joo](https://martinjoo.dev/build-your-own-laravel-query-builders)
and [this one by Tim MacDonald](https://timacdonald.me/dedicated-eloquent-model-query-builders/). Both do not overwrite
the query method, but every thing else is quite similar to this post.

```php

namespace App\Models\Builders;

use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

/**
 * @template TModelClass of \App\Models\Post
 * @extends Builder<TModelClass>
 */
class PostBuilder extends Builder
{
    public function published(): self
    {
        return $this->where('published', 1);
    }

    public function whereHasMedia(): self
    {
        return $this->where(fn (self $query) => $query
            ->whereHas('image')
            ->orWhereHas('video')
        );
    }

    public function visibleToUser(User $user): self
    {
        return $this->published()
            ->where(fn (PostBuilder $query) => $query
                ->where('privacy', 'public')
                ->when($user->isAdmin(), fn (PostBuilder $query) => $query
                    ->orWhere('privacy', 'friends')
                    )
                )
            );
    }
}
```

This will not work out of the box, how should Laravel know that we don't want to use the Eloquent Buidler?

To solve this we first have to overwrite the `query` Method to get the Typehints and autocompletion. Secondly we have to
overwrite the Model `newEloquentBuilder` method. Inside the `Illuminate\Database\Eloquent\Model` this methods usually
initiates a new `\Illuminate\Database\Query\Builder` using the `$query` parameter. As our `PostBuilder` extends this
Class, we can just use it the same.

```php
class Post extends Model
{
    /**
     * @return PostBuilder<\App\Models\Post>
     */
    public static function query(): PostBuilder
    {
        return parent::query();
    }

    /**
     * @param \Illuminate\Database\Query\Builder $query
     * @return PostBuilder<\App\Models\Post>
     */
    public function newEloquentBuilder($query): PostBuilder
    {
        return new PostBuilder($query);
    }
...
```

## Enjoy the Usage

Let's feel the joy of what we have implemented:

```php

$posts = Post::query()
    ->visibleToUser(Auth::user())
    ->paginate();

$latestPostedImage = Post::query()
    ->where('user_id', 41)
    ->whereHasMedia()
    ->published()
    ->latest()
    ->first();

$latestPostedImage = $user->posts()->published()->first();

$userWithPublishedPosts = User::query()
    ->whereHas('post', fn (PostBuilder $query) => $query->published($user))
    ->get();
```

Can you feel it? No, you can't - you have to try it to get the satisfying feeling of your IDE proposing the
Model-dependent extra methods like 'published' while typing, or when you go through old or unknown code the possibility
to click on the method and get directly to the implementation without any Laravel Plugin or searching for a ScopeMethod.

There a some additional things to mention:

* If you don't use the `query` Method (like `Post::first()`) the `newEloquentBuilder` Method will be called anyway, but
  you don't have Typehints
* Usage of the two patterns are the same, the main different is the way ScopeMethods are implemented and the two extra
  Methods in the Model
* In case your super high complexity Project can utilize it: Builder classes may share traits ;)

## Bonus:

If custom query builders is not enough for you to play with, try customising Collections [^collection-macros]. If there
is any set of collection methods you always use, or you are missing, you can just extend the Laravel Collections
yourself!

[^collection-macros]: Read through the [Laravel Docs](https://laravel.com/docs/9.x/collections#extending-collections)
regarding this

```php
class AppServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Collection::macro('firstWhereMin', fn (string $key) => $this->firstWhere($key, $this->min($key)));
    }
}
```

I am still looking for a nice way to keep my beloved autocompletion, but for just the functionality I can recommend you
to just write all the Collection methods you might miss. [^collection-spatie]

[^collection-spatie]: [Spatie has a package](https://github.com/spatie/laravel-collection-macros) with nice examples if
you are looking for something pre-build or inspiration
