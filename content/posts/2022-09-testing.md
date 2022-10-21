---
title: "Ethical Development"

date: 2022-08-31T14:20:44+02:00

draft: true

description: "TODO"

tags: ["Development", "Testing", "Unit Testing", "Laravel", "Feature Testing", "Contracts Testing"]
---

{{< lead >}}
Some info here TODO
{{< /lead >}}

## Why Tests?

There is not one reason to write tests but multiple, and therefor not only developers should be interested in writing
and enforcing the writing of tests.

### Finding bugs

The most obvious benefit of tests, they point out bugs. Writing different test scenarios for one test (after or before
you implemented a feature) will often enough reveal a bug, a missing if case, or a nullable entity you did not plan when
writing the code.

### Information about code usage

When implementing an API, a set of tests that provide test data of the most common cases and known edge cases will give
any (new) developer a grasp on what kind of data will be sent to the Server - an understanding that goes way beyond of
what is a valid set of data. Just one example would be the size of nested objects as this information might make the
difference between updating in a loop or mass updating using SQL.

### More reliable and stable product

Even if a new feature is not touching other code on first sight, it may make assumption about the code that runs before
or after. Existing tests can point where new code does not completely hook into the existing code.
A well tested software is a great source of confident in the product for the product owner, the customer, and the
consumer. As I mostly can speak for the developer point of view, I very much appreciate using a well tested API.

### Increasing confidence for developers

This is one of the most important reasons for code in my point of view. A well tested code base offers way more room for
developers to implement fast and still be sure that their code will not break the system. Big refactorings are way
easier to complete if the developers are confident that the tests cover for any changed behavior. Same is applicable for
new developers or developers, who are inexperienced in the domain. A developer who is confident in the tests can
develop faster, refactor more, and will be less stressed about pushing features to production.

## What kind of tests?

Not every test is suited for every project. Depending on the product not every test is necessary, practical, or even
needed.

### Feature Testing

As Laravel fan-girl for small projects, my first instinct is to write feature tests for each controller. Is
authorisation working as intended, are the correct meta information filled with creation, or are the related events
fired. Feature testing are the kinds of tests that make a project reliable for the customer and developer.
The downside of those tests are the amount of overheat startup time. A test suite should run fast - on the one hand
to be easy to be executed often, but also to reduce deployment time if running tests are part of deployment (it should).
For every feature test e.g. of a controller the testing environment has to be set up, a (more or less) faked database
connection needs to established, in case of laravel a container has to be set up, a Kernel get running, and a bunch of
files required [^testcontainer].
This does not need to be a problem, but surely will be if the product is getting to big.

[^testcontainer]: The [Laravel `TestCase`](https://laravel.com/docs/9.x/testing#the-creates-application-trait) is
extended in a lot of the Feature Tests. This TestCase initiates the Container and causes a some seconds for every Test
to build up the Framework to be in a testable state.

But if you want to test something like a service, something basic for which you don't need the whole container or no
database - the model factories [^factories] of laravel have a make function for a reason after all. But if you don't
extend the Laravel TestCase, you will very quickly encounter some problems. Instantiating a basic application, and then
fixing the missing Factories (which are not required without the laravel container), then realising that you are using
the Searchable Trait for Scout - which required again more dependencies.
Long story short, I can only recommend to tinker around in your application and try to get some test working without
instantiation a complete container.

[^factories]: [Laravel has factories](https://laravel.com/docs/9.x/eloquent-factories#instantiating-models) that allow a
nice way to arrange the models you need inside your test.

### Unit Testing

Unit Tests are testing minimal units on their functionality without touching, requiring, or depending on other code.
Working with the for Laravel typical Active Record Pattern, the requirement to not require a Database Connection make
writing tests quite hard. In case you write framework close code, the last paragraph might help to go in the correct
direction, but I honestly don't value unit tests as much as I probably should.

### Schema Testing 


