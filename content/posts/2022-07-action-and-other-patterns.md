---
title: "About Actions, Jobs, Repositories, Events"

date: 2022-07-31T14:20:44+02:00

draft: false

description: "Simple REST APIs are nice. But once a Controller needs to perform more than the basic update, create,
and index methods; Once a Controller maybe ought to handle multiple little tasks, tasks that may be used in various
places in the code base, there is a need for a Software Pattern. Something that fulfills the desire to have one
class or method do only one thing - Single Responsibility. This Post compares Repositories, Services, Actions, Jobs, and
Events (and gives inspiration for piptes) - not to find the best for all use cases, but to formulate some words on the
question when the different patterns
offer advantages over the others."

tags: ["Development", "Laravel", "Patterns", "Single Responsibility", "Repository Pattern", "Service Pattern", "Action Pattern", "Jobs", "Events", "Pipeline Patter"]
---

{{< lead >}} Simple REST APIs are nice. But once a Controller needs to perform more than just the basic update, create,
and index methods; Once a Controller maybe ought to handle multiple little tasks, tasks that may be used in various
places in the code base, there is a need for a Software Pattern. Something that fulfills the desire to have one
class or method do only one thing - Single Responsibility. This Post compares Repositories, Services, Actions, Jobs, and
Events - not to find the best for all use cases, but to formulate some words on the question when the different patterns
offer advantages over the others. {{< /lead >}}

## Writing a Controller that

Taking my favorite example, [Round Robin](https://round-robin.philodev.one/) - a little round-based gaming platform to
register and play games with friends. A new user just registered and already has a game token, so they can just join an
existing game. This means, within the request to (1) create that user, also a (2) player needs to be created, and (3)
that player must be configured e.g. become a member of a color-coded team.

{{< alert >}}
Of course there are reasons to do some things using precisely one pattern (like sending an email using an event, or
updating using a repository). This blog is a collection to compare some patterns that want to move code from
the controller to different files. The example is used for visualisation, not because it is so hard to decide which
pattenr to use in this case
{{< /alert >}}

![Orchestrate - but how?](/images/2022-07-orchestrate.png)

### Just a Controller

For simplicity, let's assume all security validations have been made in the request by magic. The reason for this post
is that multiple things are ought to happen in this controller, some of those things are also happening in different
parts of the application, and I need to find a pattern to organize my code.

So using nothing but the Model View Controller pattern, I end up with this code:

```php
class UserController
{
    public function register(Request $request)
    {
        // step 1: create the user
        $user = User::create($request->data());
        Auth::login($user, true);

        if (! $request->input('token')) {
            return return view('game.index');
        }

         // step 2: Create the player
        $game = Game::query()
            ->where('token', $request->input('token'))
            ->firstOrFail();
            
        $player = $game->players()->create([
            'uuid'    => Str::uuid(),
            'user_id' => Auth::id(),
        ]);
        
         // step 3: Prepare the Player for the game
        $redPlayers = $game->players()->where('color', 'red')->count();
        $bluePlayers = $game->players()->where('color', 'blue')->count();
        $player->color =   $redPlayers > $bluePlayers ? 'blue' : 'red;'
        $player->save();

        return view('GamePage', ['game' => $game]);
    }
}
```

Not very reusable... so let's have a look at the Laravel Docs and common Patterns to improve the situation.

### Repository Pattern

If there was a layer between the Database and the Controller, something that handles the creation of models - wouldn't
that be nice? Using Dependency Injection of Laravel, you could follow such a pattern:

```php
class UserController
{
    public function register(Request $request, UserRepository $userRepository, PlayerRepository $playerRepository)
    {
        // step 1: create the user
        $user = $userRepository->createUser($request->data());

        if (! $request->input('token')) {
            return return view('game.index');
        }

         // step 2: Create the player
         $player = $playerRepository->createPlayer(['token' => $request->input('token')]);
        
         // step 3: Prepare the Player for the game
        $redPlayers = $game->players()->where('color', 'red')->count();
        $bluePlayers = $game->players()->where('color', 'blue')->count();
        $player->color =   $redPlayers > $bluePlayers ? 'blue' : 'red;'
        $player->save();

        return view('GamePage', ['game' => $player->game]);
    }
}
```

The great thing about a Repository is, that it is the single point in the code base, that creates, updates, or queries
Models. There are a lot of use cases in which this can be super helpful - e.g. if you want to validate your Models
before updating or authorizing queries. The separation of the writing and reading part of a Repository can be achieved
by
using [^custom Query Builders]. The Repository does a great deal for separation of concerns and single responsibility (
your software pattern bingo game should have caused one win by now).

[^custom Query Builders]: [This Post](https://www.blog.philodev.one/posts/2022-05-custom-query-builder-pattern/) offers
some examples and sources

But it can't solve all problems, as you can see the third step is not the job of the Repository. Arguably it could be
implemented there, as one can argue that the correct color of a player is somewhat a validation topic, but treating a
Repository like that will make it the "core service" of the application soon. It is not the job of the Repository to
care
about everything that occurs with the creation of a Model, it just cares about the creation of the Model.

### Service Pattern

If there was a place to just hold all the methods that might be used multiple times - wouldn't that be nice? Mind that
this is not the Service Provider that Laravel mentions, at least I could not come up with a reason why a Service like
that would need to be registered or requires to be a singleton.

```php
class UserController
{
    public function register(Request $request, UserService $userService, PlayerService $playerService)
    {
        // step 1: create the user
        $user = $userService->register($request->data());

        if (! $request->input('token')) {
            return return view('game.index');
        }

         // step 2: Create the player
         $player = $playerService->createPlayer($request->input('token'));
        
         // step 3: Prepare the Player for the game
         $player = $playerService->initatePlayer();

        return view('GamePage', ['game' => $player->game]);
    }
}
```

Feel the freedom of doing more than just creating and updating, listen to the single Responsibility Pattern softly
crying in the corner, and watch your services grow to reach the 4-digit line numbers! Services are a great way to
encapsulate logic around one component. In my experience, it is just hard to set boundaries, and in a larger application
(or one that can have the potential to grow) I would not use this pattern and go for something that gives the next
developer
who might continue on my code a stricter line on where to find and add code.

One additional note: there is no limit on patterns, Services and Repositories might work together quite well
and [^catch each other's weaknesses].

[^catch each other's weaknesses]: [Here](https://stackoverflow.com/questions/57363816/is-it-okey-to-call-events-from-repository-pattern-in-laravel)
is an example from Stack Overflow in which this is elaborated

### Action Pattern

If there was just one class, that does exactly the one thing, and may be reused in Controllers, Jobs, Commands,
whatever - wouldn't that be nice?

```php
class UserController
{
    public function register(
        Request $request, 
        UserCreateAction $userCreateAction, 
        PlayerCreateAction $playerCreateAction, 
        PlayerInitialisationAction $playerInitialisationAction,
        )
    {
        // step 1: create the user
        $userCreateAction->execute($request->data());

        if (! $request->input('token')) {
            return return view('game.index');
        }

         // step 2: Create the player
         $playerCreateAction->exectue(token: $request->input('token'));
        
         // step 3: Prepare the Player for the game
         $playerInitialisationAction->exectue();

        // imagine there is a custom Auth Facade extending the Auth Facade ...
        return view('GamePage', ['game' => Auth::player()->game]);
    }
}
```

One Action, one class per action, one concern per class - everything is separated and clean. Using this pattern can lead
to very clean actions, that can be inside of Controllers as well as Jobs as well as Nova Actions. Every bit of the
Business Logic broken down into simple pieces. And the single Actions are just so easy to test - some unit tests per
Action will increase the Test coverage fast and if all the little gears are working half the bugs are avoided. And then
you can just avoid using Events at all, because using the right packages will enable your actions to run on
queue [^Actions].

[^Actions]: [Here](https://lorisleiva.com/why-i-wrote-laravel-actions) is one of the many Action favorable Posts. I
learned the pattern using the book "Laravel beyond CRUD".

This pattern is the reason for this post. I am working with this pattern for some months now and have to admit, it is
neat. Combined with some naming convention (spare some fuzz, suffix your actions with 'Action' from the very
beginning... and while you are at it, just suffix everything that is not a Model).

I still have my concerns: While the Project grows, so first and for most your `/actions` folder grows, there is one
feature of Actions that I see as the biggest pro and con. Compared to Events, which are created, put on queue, and in
some ballet of Laravel Magic listened to at some point; Actions stay controllable. The Controller, or what ever point of
execution is calling the Actions like a conductor is flicking their want to initiate a calculated, controlled set of
actions. In a lot of use cases, this is a great tool of control - in others the freedom of hooking in between and after
any of those actions can be integrating, sometimes even necessary. Following the Action Pattern, such add-a-hook changes
can be frustrating to implement as each conductor has to follow the new life cycle, instead of having one place in which
such a life cycle event may be added.

### Using Jobs for Action Pattern

This little question bugged me after discussing the topic with some colleagues. Why use Actions, if they could be Jobs?
Why not use the Framework that we Artisans admire, and just take the Jobs, may or may not make it Dispatchable or /
and Queueable and just use those as queueable actions without any package dependency? All the special features of Jobs,
like rerunning on error, or unique running could come in super handy.

It is like taking a sledgehammer to crack a nut, but starting a Job should not be that much of a time spent,
especially if it is not Queueable anyway. One drawback for sure is the missing option to return something from your
action, which I would argue is a bit of code smell anyway.

Honest answer to this section: No idea, would love to try, if you have a comment on that - please email me, I would
appreciate the discussion!

### Event - Listener Pattern

If we could just state what happened in the Controller, everything that wants to react to the thing that happened can
do so - wouldn't that be nice?

```php
class UserController
{
    public function register(Request $request)
    {
        // step 1: create the user
        $user = User::create($request->data());
        Auth::login($user, true);
        
        UserCreated::dispatch($user);

        return view('GamePage', ['game' => Auth::player()->game]);
    }
}

// In the Event Service Provider
protected $listen = [
    UserCreated::class => [
        // step 2: Create the player
        CreatePlayerIfTokenIsPresent::class,
    ],
    PlayerCreated::class => [
        // step 3: Prepare the Player for the game
        InitiatePlayer::class,
    ],
];
```

So little code... so clean, almost no newbie will know where to find everything, but a Laravel affine Developer might
look at the Service Provider (that might be one of many Service Providers, e.g. one for each Domain), and see how Data
might flow through the Application in a barely controllable way once the event has been dispatched.

This is the pattern of choice if your tasks should run on Queue, but any listener that misses
the `implements ShouldQueue` (which can be expressed by an empty Interface `Should RunImmediately`) is not queued at
all, but will be executed in the old PHP line by line fashion - like an Action. So Events come with most of the Benefits
of Actions, Testability, Single Responsibility; but introduce their own set of drawbacks. They are way harder to parse
in mind, can hard to follow through multiple layers of events, and are even harder to test in combination than Actions.

If you want to offer some frustrating learning experiences for Developers new to the code, Silent [^Laravel Observers]
are
using the same pattern and will listen for Model Events that are thrown automatically (this is the reason there is
a `$user->saveQuietly()` method).

[^Laravel Observers]: [Laravel Docs](https://laravel.com/docs/9.x/eloquent#observers) for more information

### Pipeline Pattern

If the steps that need to be performed are just running through a pre-defined set of classes - wouldn't that be nice?

```php
class UserController
{
    public function register(Request $request)
    {        
        $player = app(Pipeline::class)
            ->send($request)
            ->through([
                // step 1: create the user
                \App\Pipes\CreateUser::class,
                // step 2: Create the player
                \App\Pipes\CreatePlayer::class
                // step 3: Prepare the Player for the game
                \App\Pipes\InitatePlayer::class
            ])
            ->thenReturn()
            ->get();

        if (! $player) {
            return return view('game.index');
        }

        return view('GamePage', ['game' => $player->game]);
    }
}
```

This would be where I would state my experiences, advantages when designing, drawbacks on production - If I had any
experience. Looking forward to someday building a pipeline pattern. If I ever do, I might come back here to update the
post ;) However, I can give you some [^hints] on where to start understanding the pattern for yourself.

[^hints]: [A Tutorial](https://dev.to/abrardev99/pipeline-pattern-in-laravel-278p) to understand the
basics, [the Pipeline Docs](https://laravel.com/api/8.x/Illuminate/Pipeline/Pipeline.html), and
an [example of the Pipeline Pattern](https://www.blog.philodev.one/posts/2022-06-customer-search/#how-does-a-request-live-through-laravel)
in Laravels Middleware Handling.

## So what now?

The answer to the question "What pattern should I use?" is the same as for so many other questions in life: "it
depends...". Every Pattern offers drawbacks, and every pattern has use cases in which it shines with all its advantages.
In every use case there will be developers arguing there was a better pattern anyway, and some will see the bright
side of the architect's decision. For some over-the-thump-rules:

- One single point in the app that stores Models? Repository Pattern
- Only need a bunch of methods to be reusable? Service Pattern
- A lot of reusable Code snippets that work very reliable? Action Pattern
- Something that may happen on the queue? Event Listener Pattern
- Wanna build something creative and tell me how it went? Pipeline Pattern
- Multiple things of the above? Use multiple patterns

If you have more Patterns, or disagree with my opinion, feel free to send me some feedback. I am not the only one how
had this idea, so check out what other people think too [^other sources].

[^other sources]: [This blog](https://laravel-news.com/controller-refactor) did similar things to refactor a controller
in multiple ways.

Happy Coding Everyone :) 
