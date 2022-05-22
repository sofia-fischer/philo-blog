---
title: "Useful and Useless Relationship Definitions"

date: 2022-05-20T14:20:44+02:00

draft: false

description: "Programmer giving Relationship Advice - A summary about Laravel / Eloquent relationships including some
hints, advanced techniques to use and misuse relations"

tags: ["Development", "Laravel"]
---

{{< lead >}} Programmer giving Relationship Advice - A summary about Laravel / Eloquent relationships including some
hints, advanced techniques to use and misuse relations {{< /lead >}}

## Relationships are great

Relational Databases like mySql or postgres tend to have that thing called relations. There are used in almost all
Laravel Projects with a database and most Laravel developers know them and know how to use them. But not every developer
knows [the Laravel Docs](https://laravel.com/docs/9.x/eloquent-relationships) by heart and there are even some features
that are not mentioned in the Laravel Docs at all, but can only be discovered by clicking through the Eloquent code.

![Example Image with Humans, Dogs, and Toys to explain Relationships](/images/2022-05-relations.png)

This blog post wants to sum up the basic relations Eloquent offers, hinting at some special ways to define relations and
advanced techniques to create relations that might be useful for querying. However, this post does not cover the usage
of relations, their benefits for query optimization, or general explanations of how they work (for learning that I
recommend the Laravel Docs or [this Blog Article](https://geekflare.com/laravel-eloquent-model-relationship/)) - only
the definition of them.

## Example Database structure

Let's play a game, shall we? Let's have some `games`, each with a `hostPlayer`, some `players` who belong to a game and
a user. A game consists of multiple `rounds`, in each round one player is active, and all players may make a `move`
resulting in a score per round.

### Class diagram

```
{{< mermaid >}} 
classDiagram 
Move --> Round : Round has many Moves, </br> Move belongs to a Round
Round --> Player : Player has many Rounds as Active-Player, </br> Round belongs to an Active-Player
Round --> Game : Game has many Rounds, </br> Round belongs to a Game 
Move --> Player : Player has many Moves, </br> Move belongs to a Player 
Player --> Game : Game has many Players, </br> Player belongs to a Game 
Game --> Player : Player has many Games as Host, </br> Game belongs to a Host-Player


class Game { 
id
host_player_id
started_at
}

class Player { 
id
game_id
user_id
color
}

class Round { 
id
game_id
active_player_id
completed_at
}

class Move { 
id
round_id
player_id
score
}

{{< /mermaid >}}
```

## One to One

### **HasOne** and **BelongsTo**

If a model has a column containing another model's id, forming a One to One Relationship. Every Relationship has its
inverse form - if a User **HasOne** Level, a Level **BelongsTo** a User. A Model with a **HasOne**
says "the id of mine is in on another table", the standard example would be:

```
{{< mermaid >}} 
classDiagram 
User <-- Level: User has one Level </br> Level belongs to User

class User { 
id 
email 
password
}

class Level { 
id 
user_id 
over_all_score
}

{{< /mermaid >}}
```

```php
class User extends Model
{  
    public function level(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Level::class);
    }
...
}

class Level extends Model
{  
    public function user(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(User::class);
    }
...
```

### "Creative" usage of the extra Parameters

**A word on parameter naming** The `something_id` column is called `foreign_id`, while the id column of this model is
referred to as `local_id`; the model to which this foreign_id belongs is the owner model, and its id column is referred
to as `owner_id`. In Laravel it is possible to enter alternative values (other than Laravel's guessed
values `$this->belongsTo(User::class, 'user_id', 'id')`) for reasons like using `uuids` or naming conventions.

But you can use these parameters also in more creative ways, let's say you want to display the level of the user next to
a players icon:

```php
class Player extends Model
{  
    public function level(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Level::class, 'user_id', 'user_id');
    }
...
```

{{< alert "circle-info" >}}

The idea of "misusing" relations in this way is considerable, strange, not intuitive for readers, and confusing for
beginners - so maybe just don't do them. With this blog post I just want to point out, that this way of working with
relationships is possible, works for some cases great, and is kinda fun to think about.

{{< /alert >}}

If I need the relation (for eager loading, query optimization...) it is handy to take the shortcut of just using the
user_ids. The problems I want to point out:

* Using the create function will not create a user, and honestly, I have no idea what would happen or which id would be
  set there
* This query will not check if the user exists or is deleted

### Default Models

Both **HasOne** and **BelongsTo** relations may have a default which (for example for a level) comes in handy because
you don't have to store a model for a user who maybe never plays a game.

```php
    public function level(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Level::class)->withDefault(['overall_score' => 0]);
    }
```

## One To Many

### **HasMany** and **BelongsTo**

The more common One to Many relations are indistinguishable from a database perspective (if there is no `unique`
constraint on the foreign key column). The difference is the possibility of the Owner to have more than one model
belonging to it.

```php
class Game extends Model
{  
    public function rounds(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Round::class);
    }
...
}

class Round extends Model
{  
    public function game(): \Illuminate\Database\Eloquent\Relations\BelongsTo
    {
        return $this->belongsTo(Game::class);
    }
...
```

### Queries in Relations

Compared to `ofMany` adding extra queries on the relation is possible as well and can come in quite handy:

```php
class Game extends Model
{  
    public function redPlayers(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Player::class)->where('color', 'red');
    }

    public function playersWithoutMove(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Player::class)->whereDosntHave('move');
    }
...
}
```

### Using **HasOne**->ofMany

But `HasOne` also offers great options if you are often looking for one special model of a **HasMany** Relationship.
This use case is very common, so I think the `ofMany` function is underrated.

```php
class Round extends Model
{
    // latest (current) Move
    public function latestMove(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
         return $this->hasOne(Move::class)->latestOfMany();
    }

    // best Move
    public function latestMove(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
         return $this->hasOne(Move::class)->latestOfMany('score', 'max');
    }

    // best, latest move where score is positive
    public function bestLatestMoveWithPositiveScore(): \Illuminate\Database\Eloquent\Relations\HasOne
    {
        return $this->hasOne(Move::class)->ofMany(
            ['created_at' => 'max', 'score' => 'max'], 
            fn ($query) => $query->where('score', '>', 0);
        );
    }
...
```

### "Creative" One to Many Relations

Breaking it down to the minimal requirement, a `HasMany` relation requires that there is another table, which holds an
identifier that the local table holds as well.

If you look at our class diagram, for example, there is no direct connection between `Move` and `Game`, if you want the
moves of a game you have to use the `Round` as a middleman. Now let's say I want a statistic that proves that my game is
fair and that the host player does not make moves with higher scores or so - whatever reason I might have to create such
a relation.

```php
class Game extends Model
{  
    public function hostPlayerMoves(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(Moves::class, 'player_id', 'host_player_id');
    }
...
```

{{< alert "circle-info" >}}

Again, creating this kind of relationships might be smelly or hacky, but it can be handy if you keep the possibilities
in mind that relations offer.

{{< /alert >}}

### Having Things Through

Laravel provides a relation for two consecutive `HasMany` relations.

```
{{< mermaid >}} 
classDiagram 
Round --> Game : Game has many Rounds, </br> Round belongs to a Game 
Move --> Round : Round has many Moves, </br> Move belongs to a Round
Move <-- Game : Game has many Moves through Round

class Game { 
id
host_player_id
started_at
}

class Round { 
id
game_id
active_player_id
completed_at
}

class Move { 
id
round_id
player_id
score
}

{{< /mermaid >}}
```

```php
class Game extends Model
{  
    public function moves(): \Illuminate\Database\Eloquent\Relations\HasManyThrough
    {
        return $this->hasManyThrough(Move::class, Round::class);
    }
...
```

#### "Creative" HasManyThroughs

Let's say we want to display the Level of the overall Game - maybe to match with other Games or whatever. Again we can
use the additional parameters to skip some tables on the way between Game and Level. Usually, we would start at the
Game, and look for the players, look for the users, look for the levels. But both the levels and the players share the
same user_id - why not skip the User?

```php
class Game extends Model
{  
    public function levels(): \Illuminate\Database\Eloquent\Relations\HasManyThrough
    {
        return $this->hasManyThrough(
            Level::class,
            Player::class,
            'game_id', // Foreign key on the players table
            'user_id', // Foreign key on the levels table
            'id', // Local key on the games table
            'user_id' // Local key on the players table
        );
    }
...
```

{{< alert "circle-info" >}}

Again, creating this kind of relationships might be smelly or hacky, but it can be handy if you keep the possibilities
in mind that relations offer.

{{< /alert >}}

## Many To Many

Many to Many relations are the kind of relations that require a pivot table. If compared to the implementation depicted
in the examples above, where a user has a player per game I could have implemented a Many to Many relation using
a `game_user` or `game^user` or `games_2_users` table or other conventional namings for pivot tables. That would look
like this:

```php
class Game extends Model
{  
    public function player(): \Illuminate\Database\Eloquent\Relations\HasManyThrough
    {
        return $this->belongsToMany(User::class, 'game_user');
    }
...
```

The point I don't like about this is #1 the naming convention does not reflect the meaning of the relation; I prefer
calling a thing by their name, in this case, `players`. 2# The first thing especially bugs me after you start adding
more columns in the pivot table, starting with timestamps, then maybe a soft delete, and then a custom link or so. At
some point, a lot of the pivot tables I saw would have looked cleaner, and caused less code smell if they were models
from the very beginning.

This does not mean, that many to many relations are useless. As I mentioned in the last examples, there are many ways to
use the additional parameters in the relationship functions. So if you see `Player` as a pivot model, you can still
define this relation:

```php
class Game extends Model
{  
    public function users(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(
            User::class, // target model
            'players', // pivot table
            'game_id', // Foreign key on pivot player table
            'user_id', // Foreign key on pivot player table
            'id', // Parent key on the games table
            'id' // Related key on the users table
        );
    }
...
```

Any table with two foreign ids may be used as a pivot table!

### "Creative" Many to Many Relations

You may again use this information even further and again create sometimes useful relations by using the additional
function parameters. For example, if you want to have the Levels instead of the Users of a Game.

```php
class Game extends Model
{  
    public function levels(): \Illuminate\Database\Eloquent\Relations\BelongsToMany
    {
        return $this->belongsToMany(
            Level::class, // target model
            'players', // pivot table
            'game_id', // Foreign key on pivot player table
            'user_id', // Foreign key on pivot player table
            'id', // Parent key on the games table
            'user_id' // Related key on the levels table
        );
    }
...
```

## Last words

This was a collection of infos, hints, and hacks about the definition of Laravel or Eloquent Relationships. If you found
any mistakes or have additional tricks please feel free to contact me :D

Happy coding
