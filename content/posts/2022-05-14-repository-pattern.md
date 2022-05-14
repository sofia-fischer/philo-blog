---
title: "Repository Pattern in Laravel for Query Organisation - an Alternative to Scopes"

date: 2022-05-14T08:20:44+02:00

draft: false

tags: ["Development", "Software Pattern", "Laravel"]
---

{{< lead >}} TLDR: Scopes are nice, but by extending the Eloquent Builder for a Model enables you to add custom,
model-specific methods that are often used or should have a central definition {{< /lead >}}

# Scopes are great, but ...

Local scopes allow you to define common sets of query constraints that you may easily re-use throughout your
application; read more in [the Laravel Docs](https://laravel.com/docs/9.x/eloquent#local-scopes). Also, if you want to
have a definition of a scope in one central place to maybe come back and change in at one place, instead of everywhere -
a common example in practise is an `activeUser` scope (email confirmed? password not older than one year? ... ).

Scopes are great, but have two major drawbacks from my point of view: #1 no autocompletion / no "jump in your code by
clicking" on it, no type hinting. This is because drawback #2 they are executed by Laravel magics. The Framework checks
if the method you are trying to call is defined in `scope<yourMethodNameInCamelCase>` in the model and uses it then.

{{< alert "circle-info" >}} **Repository Pattern**: One of many Software Design Patterns out there. The Repository is an
abstraction Layer of Data, from this abstraction Layer the data may be retrieved using function like `Post::getAll()`
or in the case of Eloquent `Post::all()`. Most implementations of the Repository pattern I found are doing the above
step of overwriting Eloquent methods with their own `getAll` method. But instead of overwriting the Eloquent methods,
why not just extend them? {{< /alert >}}

## Writing a Repository that Extends the Eloquent Builder

The Builder that Laravel uses behind every `::query()` is the `Illuminate\Database\Eloquent\Builder`. A class that
extends this Builder for one Model offers the opportunity to add custom methods to the Builder.

Compared to Scopes I want to highlight, that neither the Scope Prefix is needed, nor the $query parameter.

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


