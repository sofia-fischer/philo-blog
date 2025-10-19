---
title: "📚 Communication Patterns"

date: 2025-07-10T10:20:44+02:00

draft: true

description: My learnings, thoughts, and key aspects of the book "Communication Patterns" by Jacqui Read

tags: [ "Book", "Documentation" ]
---

{{< lead >}}
"Communication Patterns" by Jacqui Read
{{< /lead >}}

{{< alert "comment" >}}
**Expectation Management** : This blog post reflects my personal takeaways from the book. Chapters that I did not find
interesting or relevant to my work are not covered, chapters that particularly resonated with me are covered in more
detail. In between I added information I found useful to understand the context of the book. Overall I changed the
structure and order of topics.

I will add personal opinion and context in these alerts.
{{< /alert >}}

## Communication Patters - about the book

> Successful communication is the art and science of sharing or exchanging ideas and information, using a common set of
> symbols, signs, or behaviors, resulting in shared understanding.
> — Jacqui Read, Communication Patterns
[^communication Patterns]

[^communication Patterns]: [Jacqui Read](https://jacquiread.com/books/communication-patterns/)

Communication can be hard, and the cost of miscommunication can be high. Refining existing communication patterns into
named patterns can form a toolbox for good communication and awareness of dark patterns.

A **Pattern** is a reusable solution to a commonly occurring problem within that is known to be effective.
An **Anti-pattern** on the other hand is a solution that looks right, but its consequences outweigh its benefits.

## Think about the Users Perspective

Identifying the audience / user to communicate with is key to successful communication.

* What Role does the User fulfill? How much technical knowledge does the User have? Can they understand technical terms,
  or technical diagrams like UML?
* What does the User want to know? What do you want from the User? In what level of detail do they need the information?
* What do they already know? Do they might know outdated information that needs to be corrected?

{{< alert "comment" >}}
**Diataxis** : Is a framework that helps to structure documentation based on the user needs. It answers some of the
questions above by sorting them into four categories: Tutorials, How-To Guides, Explanation, and Reference.

Tutorials: A practical lesson or introduction to a topic, guiding a user who is unknown to the topic through a series of
steps to learn how to solve future problems, by solving a example problem.

How-To Guides: A step-by-step guide to accomplish a specific real world task, for users who know what they want to do
and focus on work rather than study the topic.

Reference: A technical description for the user who needs to look up specific information to continue work.

Explanation: A deep dive into the background and context of a topic, for users who want to understand why the system a
given way.
{{< /alert >}}
[^diataxis]

[^diataxis]: [Diataxis Framework](https://diataxis.fr)

## Visual Communication

### Which diagram to choose?

{{<mermaid>}}
graph TD
A[Patterns and Best Practices for choosing the correct Diagram]

    A1(["❌ Wrong Diagram for the User"])
    A2(["❌ Mixing Levels of Abstraction"])
    A2b@{ shape: odd, label: "🛠️ C4 Model" }
    A3(["🏅Representational Consistency"])
    A4(["💡Single Responsibility"])

    %% Links
    A --> A1
    A --> A2
    A --> A3
    A --> A4
    A2 --> A2b

    %% Style

{{< /mermaid >}}

#### Anti Pattern: Choosing the wrong Diagram for the User

Different Users will understand and appreciate different diagrams. Talking in stereotypical roles, the steak holder who
wants to understand the system would prefer a User Journey over a Class Diagram, while a Developer would probably gain
quite some information from the latter.

The goal should be to choose a diagram that the User is familiar with, that will match their question or conveys the
message they should receive, and it should contain the amount of detail that the User needs.

#### Anti Pattern: Mixing Levels of Abstraction - Solution: C4 Model

Developer Example:

```python
def feed(corgi: Corgi) -> None:
    # easily readable level of abstraction
    if corgi.is_fed():
        return
    food = _get_food()
    corgi.ate.appent(food)
    # awkwardly detailed level of abstraction
    corgi.last_fed = datetime.now()
    corgi.save()
    # the last 2-3 lines could have been a method,
    # making this much more readable. 
```

[^abstraction]

[^abstraction]: [Mixing levels of abstraction](https://medium.com/thinkster-io/code-smell-changing-levels-of-abstraction-521cfc8094a2)

Every diagram will be an abstraction of something, but not everything that can be useful for the reader should be
compressed into one diagram. Individual tickets do not belong into a roadmap, as it would clutter the model or even
raise the questions what these little details mean if they are so important to be mentioned here.

One Solution to this is offered by the C4 Hierarchy of abstractions. Starting from a big picture it starts with the *
**System Context** in which the system interacts with its environment.
The **Container** level displays the components of system with their interaction in between them or the external
entities.
While the **Component** levels zooms into one Container of the last level and dissects its subcomponents.
The finest level is the **Code**, which reveals actual implementation.

#### Best Practice: Representational Consistency

When working with multiple diagrams, for example after applying the C4 Model, all references to the same component,
role, entity should be easily identifiable as the same. With diagrams, we often do not have the luxury to step in and
out of details with one click or having a compiler checking that naming is consistent over multiple diagrams.
A role could be named the same and use the same pictogram; a component could be named the same and be framed by the
same symbol and color in a system context diagram and a container diagram.

#### Best Practice: Single Responsibility

This commonly known software pattern describes that a building block should only have a single responsibility.
The most repeated reason for this is maintainability, as there is also only one reason to change; giving a block of code
a single responsibility makes it wat easier to understand. The same applies to diagrams, if a diagram tries to convey
multiple messages, it will be hard to understand and less effective in conveying that message.

The main differentiation of responsibilities are between *Behavior* and *Structure*.
Behavior diagrams like Sequence Diagrams show how the system achieves which goal.
Structure diagrams like Class Diagrams show what the system is made of and who it interacts with.

{{< alert "comment" >}}
I see the point how even any reporting diagram can be sorted into these two categories, but when designing a diagram I
would find it useful to have more responsibilities as inspiration what the responsibility of the diagram could be.

* **State** : What states a system can reach or what life cycle can be mapped.
* **Reporting** : What is the historic, current, or future performance of a system.
* **Observability** : Modelling what structures can be observed while they behave in a certain way.
  {{< /alert >}}

### Diagram Layout



