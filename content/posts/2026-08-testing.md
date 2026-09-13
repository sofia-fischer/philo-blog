---
title: "Testing does more than finding bugs"

date: 2026-08-13T08:20:44+02:00

draft: false

description: "Tests can do so much more than spotting bugs! Let me share my enthusiasm to write tests because 
they document behavior, because tested code can be of higher quality, and tests improve the understanding of 
the domain!"

tags: [ "Testing", "Documentation", "Tools" ]
---

{{< lead >}}
Tests can do so much more than spotting bugs! Let me share my enthusiasm to write tests because they document
behavior, because tested code can be of higher quality, and tests improve the understanding of the domain!
{{</lead >}}

## Testing is here to help

> Tests are the most common code duplication I have ever encountered.

A quote from a lead developer in my first job as a developer. In the time I grew from computer science
student to software developer the overall mindset of tests changed fundamentally around me.
Back in that company we had to test the code we wrote by trying the feature out locally, and then the product manager
again tested the feature. Hoping that both people tested different cases, hoping that the developer who did the review
maybe also tested it, manual testing might have been the most common task duplication in that company. Manual testing is
limited and will focus on one thing: finding bugs.

Framing testing as something that only catches bugs is underestimating the versatility of one of my favorite areas of
computer science.

We are coding complicated things, our code is complicated enough to require multiple people to implement it, it requires
careful definition of requirements, it requires documentation to be understood, it requires a second thought before
merging, it requires an agreed set of coding standards to ensure quality. In my point of view, testing can be a tool in
all of those stages of software development.

### Testing will not find all the bugs

When talking about the qualities of a test set, many refer to the coverage - a map of all the lines of code that are
touched by any test. It can be used as a tool to identify missing test cases or missing tests and by that raise the
question if the code is reachable at all, or if the use case is thought through.

> Pesticide paradox: every method you use to prevent or find bugs leaves a residue of subtler bugs against which those
> methods are ineffectual (Boris Beizer)[^pesticide_paradox]

[^pesticide_paradox]: Boris Beizer (I came across it in "Effective Software Testing")

[^effective_testing]: *Effective Software Testing* by Maurício Aniche.

Just because a line is touched by a test, does not mean it is bug free. Edge cases can hide in obscure places and while
for most bugs in hindsight a test could be written, ex ante this is not reasonable. If the test is copying the
behavior of the function to test, it might copy an existent bug. And even if the test and the code were written
perfectly, a test will not identify if the code is covering the requirement.

Effective testing should aim for the lowest number of tests that still cover most of the bugs. A test that does not
represent a reasonable use case or document an important behavior has in my point of view very little value.
In my experience AI agents make this problem worse. I watched AI agents design tests that increased line
coverage without increasing branch coverage, or write assertions that existed only to satisfy the type checker and do
not cover real business cases. [^effective_testing]

In my opinion, tests should not test unreasonable use cases, should not test framework behavior, should not test
things that should be changed with ease (like log messages or error messages). If a test is annoying, because it only
functions as a barrier to change the code, it is not the helpful tool it can be.

A well built test suite can give developers confidence to change the code and can make development faster. My
main learning from [The Refactoring Book]({{< ref "posts/2026-02-refactoring" >}}) was that if the tests are
purely testing behavior and not implementation, every step of refactoring can be done without a breaking test.
Even a bigger code change can this way be easily justified and proved successful.

## Good tests can do so much more

### Tests can test small units and a whole system for its intended behavior

The smallest and simplest form of a test is a <mark>Unit Test</mark>. I define unit test as a test that does not
require dependencies - no database, no framework, nothing that I need to initialize or set up to run the test.

Depending on how the code is designed this can mean testing a very specific piece of code or it can mean testing a
whole layer. Even if there is a small number of dependencies they can be mocked or injected with classes that are
suitable for unit tests. Unit tests are blazingly fast, and the benefit of running thousands of them in seconds can be
a great developer experience. I worked in code bases that were designed from the very beginning as hexagonal
architecture focused on fast unit tests and in code bases with loads of integration tests in heavily coupled code -
the time to run the test suite has a big impact on how often I would use tests.

Side note on mocks: any dependency that seems too complicated or too slow (or that you need to behave in a certain
way) can be mocked away - but what is mocked is not tested. Using mocks to assert something was
called or used is only ever testing implementation, not behavior. I find mocks a very important magic tool, but it
should be used with care.

<mark>System Tests</mark> on the other hand set up everything, start on the edge of the system and run through a
user flow through the system. Especially for those tests it is important to test the result: whether the entity that
performs the action achieved their goal, usually whether the data was manipulated as intended.
The great benefit of these tests is that they give confidence that even if you change something in your code, the
most important user flow will still run through as intended.

### Tests can test examples

When I explain a concept to a person, my sentence might just start with "I'll give you an example". A test can be
just that. Here is the simplest happy path through the system. Now that you got that, here is an edge case I find
important for understanding.

A handy tool for testing examples can be test parameters:

```python
def golden_ratio_for(a: float) -> float:
    if not a >= 0:
        raise ValueError("a must be >= 0")
    phi = (1 + math.sqrt(5)) / 2
    return a * phi


@pytest.mark.parametrize(
    "given_a,expected_b",
    [
        pytest.param(0, 0, id="Zero should return Zero"),
        pytest.param(1, 1.618, id="One should return the golden ratio"),
        pytest.param(2, 3.236, id="Two should return two times golden ratio"),
    ],
)
def test_golden_ratio_for(given_a: float, expected_b: float) -> None:
    assert round(golden_ratio_for(given_a), 3) == expected_b
```

Examples are stable, predictable, and can represent a specific use case.

A special case of example testing is <mark>Snapshot Testing</mark>. Given a complex pipeline of steps, e.g. in
parsing, it can be extremely helpful to assert that a given message is processed to the same deterministic result.
Any difference in the result compared to the expected snapshot file will cause the test to fail. A
change in the parser can be verified in the created diff to the existing snapshot, and the snapshot can then be
updated.

### Tests can test ranges and properties

Why bother coming up with exact test examples, if one can just generate them randomly?
Leaving behind the stability of fixed examples with <mark>Property Testing</mark> increases the tested space as
well as the challenge of now having to fully understand what the boundaries and postconditions of the code are.

```python
def golden_ratio_for(a: float) -> float:
    if not a >= 0:
        raise ValueError("a must be >= 0")
    phi = (1 + math.sqrt(5)) / 2
    return a * phi


def test_golden_ratio_for() -> None:
    given_a = random.uniform(1, 9999999)
    resulted_b = golden_ratio_for(given_a)
    assert (
            ((given_a + resulted_b) / resulted_b) == pytest.approx(resulted_b / given_a)
    ), f"Oh no, {given_a} resulted in {resulted_b} and is not in the golden ratio"
```

Properties of code can be tested by

* assuming a different function returns a stable output afterward ("Given any logged in user, the `logout` function
  should invalidate their session")
* generating test data that will result in a known result ("splitting a fixed invoice into random line items that
  still match the given amount")
* Testing post conditions ("the result will be bigger than the input")
* Randomizing a list of operations with a fixed result ("putting 2 items and removing them in a cart with 3 items in
  any order should result in 3 items in the cart")
  [^effective_testing]

Just very precisely describe what exact data caused which error to avoid hunting down flaky tests, which can for
example be achieved by property testing libraries.

### Tests document behavior and intention

If I look at code that seems to make no sense to me, I look at the test. Different test cases can (and should) answer
questions about the code itself.

* What is the code intended to do, what is the result?
* What are the limits of the code, what behavior is out of scope? What is the simplest use case?
* What preconditions does the code assume? In which state of my data should I call the code?
* What postconditions or what invariants can I assume when working with the result?

There even are <mark>DocTests</mark> that are designed to be executable doc strings that function as documentation and
test in one.

```python
def golden_ratio_for(a: float) -> float:
    """
    Given the non negative quantity a, return non negative quantity b
    such that a and b are in the golden ratio Phi

    >>> [round(golden_ratio_for(n), 3) for n in range(0, 5)]
    [0.0, 1.618, 3.236, 4.854, 6.472]

    Will only work for numbers >= 0
    >>> golden_ratio_for(-1)
    Traceback (most recent call last):
        ...
    ValueError: a must be >= 0

    Will work with floats
    >>> round(golden_ratio_for(3.14), 3)
    5.081
    """
    if not a >= 0:
        raise ValueError("a must be >= 0")
    phi = (1 + math.sqrt(5)) / 2
    return a * phi
```

In complex software systems DocTests might not be sufficient to test the whole code base. But they don't need to be the
only test you have, and they are not the only way to write tests in a way that focuses on readability and documentation.

```python
def test_create_user_task_when_sending_empty_message() -> None:
    """
    If by any chance we send out a message without content, like in the 2002 incident,
    ensure that we don't just send them - but create a task to alert a human...
    """
```

Tests can be the tool to fix a bug, a documentation on what happened and what worked to handle the complex system that
we are working in.

### Tests can ensure contracts

Within complex systems there are borders with specified connection points. That can be an HTTP API between two
services, or a message/event bus, or it can be a function that is consumed by one team and owned by a different team.

Those connection points are in special need of testing, because tests are often the only way the people who are
owning the code are actually using it. With a test, at least once a developer looked at the system and tried using
it themselves. The mindset of testing might make it easier to see possible ways of using the function in a wrong way
with or without bad intentions, and by that make the system easier to use and more resilient.

Every connection point comes with a contract. That might be the HTTP schema of the result it will return or just the
list of typed parameters. In this contract there are also definitions about the behavior, about the preconditions that
the function will assume and the post conditions it will guarantee. Changing such a contract will break the consuming
party - which in this case is the user.

{{< alert "circle-info" >}}
**Barbara Liskov's Substitution Principle** is applicable to contracts: Objects of a subtype should be usable wherever
the supertype is expected, without changing correctness. You may weaken a precondition but not strengthen it (if the
input always were numbers greater than 0 you may allow 0, but you may not introduce a new restriction to forbid 1); you
may strengthen a post condition or an invariant, but not weaken it; and the result may not become mutable where it
wasn't before (Historic constraint).

The consumer wrote their code against an existing contract. It promises not more than what is given in the contract,
and it relies on not less than what the contract did offer.
{{< /alert >}}

A test can here as well be a user requirement. As a developer using this function I rely on the input parameter
number being a positive float, and the return value I expect must be greater or equal than the input; I expect that
exceptions will have an error message; I expect that the function returns the same result on the same input
parameters...documenting such requirements as tests ensures that they will be reliable in the future, not only
because a test fails if a developer is changing the code, but because the test explains and documents that there is a
reason for a certain behavior.

One common way to write <mark>Contract Tests</mark> is [Pact](https://docs.pact.io), a framework that will
replay the user defined responses to ensure that the producer's code matches the contract and cause a failing test
if it doesn't.

### Tests can ensure code quality and architecture standards

As established, the users of code are also developers. To ensure that the system can only be used as intended can
also mean writing tests that ensure that code can only be written in a certain way.

In the simplest form that can mean that "unwritten" (or even written in a comment) laws are followed. There can be a
test that ensures that if an enum value is added, that a translation is added for the front end; a test that ensures
that if a new handler is added that it is detected by the registry; a test that ensures that if a code reference is
given in the documentation, that it exists in the code base. Tests can offer friendly help and guidance to the
user.

It can also be tested if the code complies with the intended architecture. An import linter can test if the domain
layer is only importing the intended classes, or that adapters only depend on each other through their ports.
This is more than nudging developers, if implemented well this is a way to communicate architecture decisions in a way
that every new joiner has a quick learning curve on what is expected.

And even one step further are (architecture) fitness functions, a concept I first heard of in the book "Building
Evolutionary Architectures" and wrote about in [this post]({{< ref "posts/2024-09-evolutionary-architecture" >}}).
Given that you can write code that tests for certain fitness criteria (like import directions, or number of queries
executed) you can step by step move the code base in a direction that fulfills your architecture goals.

Such nudges don't need to be dedicated tests, but can be hidden in the test helpers. Maybe the test helper
that simulates sending a request automatically compares the request to the OpenAPI file; or maybe the helper that
calls the database is checking for n+1 query problems.

## Think like someone who writes tests

The testing mindset helps to understand the system. What is the requirement, what are the boundaries and edge cases?
How should the system not function? What are pre- and postconditions? Well written tests are a sign of a well
understood domain.

Tests should be easy to read and to write. That is not the case when there are 20 different private helper functions
that set up an account, but when there is one helper function that defines what an account requires in its simplest
form. If it is a common problem for tests to initiate database models in a certain state, build a factory that does
that. If there are the same setup steps in many tests, build a helper that names what is set up instead of repeating
it everywhere. Writing tests with a nice User Experience is not trivial, and it requires some experience and a bit
extra effort to write them.

The AI agents I use barely share my enthusiasm if I don't ask for it. I use agents to improve my tests and my
approaches on what to test, with which benefits or drawbacks. But I also see a significant amount of code produced by
AI added to the test folder. My agents seem to love private helper methods, initiating data structures that are either
far away from reality or way too detailed compared to what is tested. AI agents can acquire better standards
for tests (after all, that's also what they do for all the other code), but you need to value tests to teach your
agent to do that too.

Tests should be user-friendly. They should not be annoying, they should tell the developer what went wrong, they
should not be slow, and they should not be flaky.

## Conclusion

Compared to the testing setup I started with some years ago to now I grew my love for testing, and its variety. This
post only scratches the surface on the newest testing methods like mutation testing or monkey testing, but that is 
something for a different post.  

You don't need to write tests to catch bugs, write them because they document behavior, because developers who think
about tests understand the domain better, because tested code can be of higher quality.

Happy testing :)
