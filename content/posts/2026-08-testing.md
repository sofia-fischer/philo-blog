---
title: "Testing is here to help"

date: 2026-08-14T08:20:44+02:00

draft: true

description: "TBA"

tags: ["Communication", "Leadership", "Books"]
---

{{< lead >}}
LOL
{{</lead >}}

## Testing is here to help

> Tests are the most common code duplication I have ever encountered.

A quote from my first lead developer who changed me from a computer science student to a software developer. While I still respect that developer, in this specific toj

Back in that company we had to test the code we wrote, and then the product manager again tested the feature. Hoping that both people tested different cases, hoping that the developer who did the review maybe also did test it, manual testing might have been most common task dublication in that comapny. Manual testing is limited and will focus on one thing: finding bugs. 

The main flaw in thought that my former lead made probably was, that the purpose of tests is catching bugs. Calling testing as something that only catches bugs is underestimating the versatility of one of my favorite areas of computer science. 

We are coding complicated things, our code is complicated enough to require multiple people to implement it, it requires careful definition of requirements, it requires documentation to be understood, it requires a second thought before merging, it requires an agreed set of coding standards to ensure quality. In my point of view, testing can be a tool in all of those stages of software development. 

### Test is not there to find all the bugs and test all the things! 

Coverage (a map of all the lines of code that are touched by any test) can be one tool a developer may use. It can be used to identify missing test cases or missing tests and by that raise the question if the code is reachable at all, or if the use case is thought throug. But code will not magically be bug-free and perfcect if one would achieve 100% coverage. 

> Pesticide paradox: every method you use to prevent or find bugs leaves a residue of sublter bugs against which those methods are ineffectual [^effective_testing]

[^effective_testing]: Effective Software Testing

Just because a line is touched by a test, does not mean it is bug free. Edge cases can hide in obscure places and while for most bugs in hindisght a test could be written, ex ante this is not reasonable. Effective testing should aim for the lowest number of tests that still cover most of the bugs. While I would argue AI agents worsen the problem, if the test is copying the behavior of the function to test, it might copy the bug. And even if it was written with care, if the code is not covering the requirement a test will discover this. 

A well build test suite can give developers confidence to change the code. The main learning from [The Refactoring Book]({{< ref "posts/2026-02-refactoring" >}}) was for me that if the tests are purly testing behavior and not implementation, every step of refactoring can be done without a breaking test. Even a bigger code change can this way eaisly justified and proofen successful. 

## What tests can do

### Tests can test code intended vs code implemented

The smallest and simplest form of a test is a <mark>Unit Test</mark>. They ensure that a small unit of code is working as intended. I define unit test as a test that does not require dependencies - no database, no framework, nothing that I need to initalise or install beyond the language. 

The big benefit of unit tests is that they are blazingly fast. Thousands of unit tests can run seconds if correctly set up. They come with the downside of being very coupled to the code itself. Their goal is to test one step, not the whole processing step. Bugs may happen when a datastructured is handled between different functions although each of the function itself has a carefully designed unit test. They are also the most fragile tests that require often refactoring if the respective unit they test is restructured. 

### Tests can test examples

The most common way of testing is by examples. A handy tool for testing examples can be test parameters:

```python
def golden_ratio_for(a: Decimal) -> Decimal:
    if not n >= 0:
        raise ValueError("n must be >= 0")
    phi = (1 + math.sqrt(5)) / 2
    return a * phi

@pytest.mark.parametrize(
    "given_a,expected_b",
    [
        pytest.param(0, 0, id="0"),
        pytest.param(1, 1.618, id="1"),
        pytest.param(2, 3.236, id="2"),
    ],
)
def test_golden_ratio_for(given_a: Decimal, expected_b: Decimal) -> None:
    assert round(golden_ratio_for(given_a), 3) == expected_b
```

Examples are stable, predictable, and can represent a specific use case. 

A special case of example testing is <mark>Snapshot Testing</mark>. Given a complex pipeline of steps, e.g. in message processing it can be super helpfull to assert that a given message is processed and results in the same parsed or even responded message. Small differences in the result compared to the expected file will cause the test to fail. If the parser is updated the snapshot file can be compared to the old file to ensure that the changes in code result in the intended changes in the example file and can then be updated to be the new expected file. 

```
def test_edifact_to_json():
    input_edifact = 'snaphshot_test_1.txt'.read_text()
    output_json = parse_edifact(input_edifact)
    snapshot.assert_match(output_json, 'snaphshot_expected_1.json')
```
(Example code, I don't have experience in python on what snapshot test framework to use)

### Tests can test ranges and properties

Why bothering coming up with exact test examples, if one can just generate them randomly? Tempting, although in reality (in my experience) quickly more work than expected. Leaviing behind the stability of fixed examples with <mark>Property Testing</mark> leaves one with a much bigger tested space and the challange of now fully understanding what the boundaries of the test data can be and how to define the post conditions of a function. 

```python
def golden_ratio_for(a: Decimal) -> Decimal:
    if not n >= 0:
        raise ValueError("n must be >= 0")
    phi = (1 + math.sqrt(5)) / 2
    return a * phi

def test_golden_ratio_for(given_a: Decimal, expected_b: Decimal) -> None:
    given_a = Decimal(random.random(0, 9999999))
    resulted_b = golden_ratio_for(given_a)
    assert ((given_a + resulted_b) / given_a) == (given_a / resulted_b), f"Oh no, {given_a} resulted in {resulted_b} and is not in the golden ratio"
```

The easest way to test a random test set is to just test that the function will handle any input in a range gracefully. If possible and known it would be great to test conditions that are true after the function was called ("Given any logged in user, the `logout` function should invalidate their session"). If such a setup is not easily possible one can still generate the test data in a way that the result is already known and fixed, like splitting a fixed invoice into random line items that still match the given amount. 

Depending on the nature of the functions to test, it would be a property test to call a combination of functions (e.g. add and remove element from list) after which the result is known, or for commutative functions a set of function calls in random order after which the result is still the same. 

I have limited experience with property based testing, and I have a certain respect for this testing style. My biggest learning so far is to very precisly describe what exact data caused which error to avoid hunting down flaky tests.


### Tests document behavior and intention

If I look at code that seems to make no sense to me, I look at the test. Different test cases can (and should) answer questions about the code itself. 

* If the code functions as imagined, what is the code inteded to do, what is the result? 
* What are the limits of the code, what behavior is out of scope? What is the simplest use case?
* What preconidionts does the code assume? In which state of my data should I call the code?
* What postconditions or what invariants can I assume when working with the result?

There even are <mark>DocTests</mark> that are designed to be exectuable doc strings that fucntion as documentation and test in one. 

```python
def golden_ratio_for(a: Decimal) -> Decimal:
    """
    Given the non negative auantity a, return non negative quanity b
    such that a and b are in the golden ration Phi

    >>> [round(golden_ratio_for(n), 3) for n in range(0, 6)]
    [0, 1.618, 3.236, 4.854, 6.472]

    Will only work for decimals >= 0
    >>> golden_ratio_for(-1)
    Traceback (most recent call last):
        ...
    ValueError: n must be >= 0

    Will work with floats
    >>> round(golden_ratio_for(3.14), 3)
    5.081
    """
    if not n >= 0:
        raise ValueError("n must be >= 0")
    phi = (1 + math.sqrt(5)) / 2
    return a * phi
```


In complex software systems DocTests might not be sufficient to test the whole code base. But they don't need to be the only test you have, and they are not the only way to write tests in a way that focuses on readability and documentation. 


```python
def test_create_user_task_when_sending_empyt_message() -> None:
    """
    If by any chance we send out a message without content (like in the 2025 incident), 
    ensure that we don't send them out but create a task to check what went wrong... 
    """
```

Tests can be the tool to fix a bug, a documentation on what happened and what worked to handle the complex system that we are working in. 



_____


Tests do find bugs, give confidence, document behavior, ensure contracts stay working, keep standards high

### testing has limits and thats ok

Coverage is not helpfull - mutation testing might be

Verificatio is bout having the right system, validatio is about having he system right

QUESTION: how does spec driven development change testing?

Complexity measures as test coverage indicator

## Types of testing

### unit tests / integration tests / system tests

integration = tseting system together
system = realistic flow with all subsystems

#### contract testing 

contract can mean things
  - an open API file
  - a function used by a different team or component
  - a datastructure used by a different team or component

  => changing contracts causes problem, so ensure with tests that your contracts ac
  => also nice benefit it makes you think about how your things are used and consumed

contracts and liskoves substition principle => stricter will not cause clients to brea, weaker might

PACT as contract testing tool especially for that


### Architecture testing

fiteness functions for arichtecture, eg query count

tests on how to use the system (eg if added enum, add a translation)

test to ensure code quality is there, import linter or 

## other

### mocking

mock if you have 
- dependencies you don't want to test or setup
- external dependecies
- hard to simulate eg exceptions
- things yo want to controll eg env / settings

fakes vs mocks: eg local repo

test state or results not if called (google?)


if you need too many mocks, maybe your code is too dependent?

### how to write a test

- what is the requirement
- how should it function
- what are boundaries and edge cases
- how should it not function
- what are pre and post conditions and are they handled
  - Post conditions are cool, they fail instead of returning faulty results
- invariants => things that always hold and are true regardless of state
- tools
  - use test data builder => customize them
  - have helpers for common setup, eg to get web set up, to get invoice, to give invoice a certain state
  - provide methods to set the system into the state that is worth testing
  - tests should be easy to write
  - tests should be readable
- minimise test data, use good mocks
- consider or don't use in memory dbs
- don't test for coverage => tst should habe a reason to exist
- tests should be fast, independent, isolated, NOT FLAKEY 
  - most flakey tests are flakey from the start on
  - often external things, e.g. timezones
- tests should have strong, readable, assertion
  - clear reason to fail
  - don't test logs or ui texts
  - tests are coupled to production, but you should minimze how they are coupled => test behavior not implementation
- duplication vs private methods inside the test class is a smell in my opinion
  - => refactor your tesets

## testable code is better

- domain code and infra code can be separated to be testable
- single responsability is easier to test and easier to understand
- code that covers more complaex corner cases is complexer to test and understand
- testing the a api / function / etc means using it once and see how hard it might be to use
  - how easy is initaliasation / method inputs
  - how many dependencies does the class have
  - reseult may be easy to verify in the return 
- dependenciy injection is nice for testing => if something is dependet on another class meke it in a way that it can easily be mocked
  - more explicit dependencies
- testable code is easier to observe => at getters for state that are used in tests / have a return value of what they created
- Hexagonal architecture can be a nice pattern, easy to test, easy to work from port to adapter (like ux first)

## TDD 

Conept: look at requirement => write a test that fails => adapt code until code passs

=> quick feedback, testable code, discovery process, feedback about design and missing cases

=> good for learning, not good if the problem is already solved
