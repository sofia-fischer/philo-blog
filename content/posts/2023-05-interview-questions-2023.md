---
title: "Job Interview questions 2023"

date: 2023-05-06T14:20:44+02:00

draft: true

description: "Uncannily like about the same time last year, I again collect technical Interview questions.
Here are some of my favorites, including my (rethought) answers."

tags: [ "Agile", "Developer Life" ]
---

{{< lead >}}
Uncannily like about the same time last year, I again collect Interview questions. Here are some of my
favorites, including my (rethought) answers.
{{< /lead >}}

## Technical Questions

### What do you like dislike on Laravel?

First, I really dislike the JsonResponse.
For development Pleasure, everyone enjoys the typing, but once the data leaves the application, it's an others dev
problem.
Sure, using the correct casts everywhere will result in correct types on the response, but it's not enforced.
If it was a class, with typed properties, it would be enforced.

In the last year I got way deeper into testing! I enjoy the Unit Testing framework of Laravel, and find it has a great
readability.
But if I don't want to run end-to-end tests, If I don't want to boot the whole application, don't need Database access,
don't extend the Laravel Test Case the most bugging feature (in my point of view) of Laravel is Facades.
Such an easy way to access the functionality of a class, but such a hard way to test it - because it requires the whole
application to be booted.
Most times it is super easy to refactor the code to not use the dependency Injection instead of the Facade.
Little change for the implementation, big change for testability.

With Facade:

```php
public function __construct() {}

public function report(ProgressReport $report)
{
    Log::debug('progress', $package);
}
```

With Dependency Injection:

```php
public function __construct(
    private LoggerInterface $logger
) {
}

public function report(ProgressReport $report)
{
    Log::debug('progress', $package);
}
```

### Best latest feature in PHP or Laravel?

For Laravel, the better typing is pretty awesome.
For PHP:

* Readonly Classes are awesome for great projects
* The spreading operator (`['a', 'b', ...['c', 'd']]`) works for string keys as well

### What Feature are you missing in PHP and how do you cope it?

I'd go for Generics here. Besides the nice possibilities you have when writing functions, just being sure what an array
contains would be nice. Side note, it seems to be hard to implement into php because of performance issues. 

And the expected answer that the other person wants to hear is: "Php Stan, when correctly used will fix it for you."
I honestly can not agree, it works okayish for simple arrays, and will help with autocompletion (lets be honest, half of
the pleasure of Generics comes from autocompletion), but in production it will not fail if you pass the wrong type in
it.
Secondly, Having a function that will accept an array of different Models, but sure will return an array with the same
type is not enforced by Php Stan.

### What tools do you always use?

* PHP Storm as IDE
* Docker for development (at leas locally)
* Github for Version Control and Deployment
* Rector, Php Stan, for Code Quality, and Code Style

Happy coding!
