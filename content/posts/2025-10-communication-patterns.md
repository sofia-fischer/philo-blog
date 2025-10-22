---
title: "📚 Communication Patterns"

date: 2025-10-10T10:20:44+02:00

draft: false

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

Giving the following bad example:

{{< mermaid >}}
gantt
title Time People need to understand this Diagrams
dateFormat YYYY-MM-DD
section Questioning Diagram Type
❌ Why is this even a Gantt Chart?!                              :2025-01-01, 30d
🛠️ C4 Diagram would barely help here...                          :2025-01-05, 20d
C4 🤓 Context-Container-Component-Code                           :2025-01-10, 25d
❌ Why explaining the C4 if nothing else is explained?           :2025-01-20, 25d
section Questioning Content
🏅 Does this match the upcoming headings?                        :2025-01-05, 30d
💡 Is this even content or a just a bad example?                 :2025-01-20, 25d
{{< /mermaid >}}

#### ❌ Anti Pattern: Choosing the wrong Diagram for the User

Different Users will understand and appreciate different diagrams. Talking in stereotypical roles, the steak holder who
wants to understand the system would prefer a User Journey over a Class Diagram, while a Developer would probably gain
quite some information from the latter.

The goal should be to choose a diagram that the User is familiar with, that will match their question or conveys the
message they should receive, and it should contain the amount of detail that the User needs.

#### ❌ Anti Pattern: Mixing Levels of Abstraction - 🛠 Tool: C4 Model

Developer Example:[^abstraction]

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

[^abstraction]: [Mixing levels of abstraction](https://medium.com/thinkster-io/code-smell-changing-levels-of-abstraction-521cfc8094a2)

Every diagram will be an abstraction of something, but not everything that can be useful for the reader should be
compressed into one diagram. Individual tickets do not belong into a roadmap, as it would clutter the model or even
raise the questions what these little details mean if they are so important to be mentioned here.

One Solution to this is offered by the C4 Hierarchy of abstractions. Starting from a big picture it starts with the
**System Context** in which the system interacts with its environment.
The **Container** level displays the components of system with their interaction in between them or the external
entities.
While the **Component** levels zooms into one Container of the last level and dissects its subcomponents.
The finest level is the **Code**, which reveals actual implementation.

#### 🏅 Best Practice: Representational Consistency

When working with multiple diagrams, for example after applying the C4 Model, all references to the same component,
role, entity should be easily identifiable as the same. With diagrams, we often do not have the luxury to step in and
out of details with one click or having a compiler checking that naming is consistent over multiple diagrams.
A role could be named the same and use the same pictogram; a component could be named the same and be framed by the
same symbol and color in a system context diagram and a container diagram.

#### 💡 Best Practice: Single Responsibility

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

After choosing a fitting diagram type, the layout of the diagram should be designed to easily convey the message to the
User.

A bad example would be:

{{< mermaid >}}
graph BT

subgraph Topics
subgraph Antipatterns
A1(["❌ Boxes in Boxes in Boxes"])
A2(["❌ Relationship Spiderweb"])
end
subgraph Proven Patterns
A3(["🦚 Create Visual Balance"])
A4(["💡 Match the Expectations, Tell a Story"])
end
end
subgraph Current Chapter
A[Patterns around Diagram Layout]
end

    %% Links
    A --is about and first topic--> A1
    A --is about--> A2
    A --is about--> A3
    A --is about--> A4
    A1 --second topic--> A2
    A2 --third topic--> A3
    A3 --fourth topic--> A4

{{< /mermaid >}}

#### ❌ Anti Pattern: Boxes in Boxes in Boxes

Boxes are a great tool to group related items together, if done correctly they can be used to indicate consistent
entities over multiple diagrams, e.g. if the box that represents a Component in a Container Diagram is the same as the
box that contains a component Diagram.
However, boxes within boxes can quickly lead to confusion, and can then cost more time to understand the
diagram.

A possible developer analogy might be nested functions, or nesting function logic into multiple levels of classes.

**=> White Space reduces Cognitive Load, while lines and boxes increase it.**

#### ❌ Anti Pattern: Relationship Spiderweb

The connection between diagram elements should have a defined meaning, which should be consistent over the diagram and
easy to be identified by the User.

Examples of Relationships are:

* Hierarchical: Illustrating parent-child connection, like in taxonomies or organizational charts.
* Sequential: Progress of steps or stages, like in flowcharts or step-by-step guides.
* Causal: Showing cause-effect relationships, like in decision trees.
* Spatial: Representing physical or conceptual proximity, like in mind maps.
* Proportional: Indicating relative scale or size, like in pie charts or bar graphs.

Mixing multiple types of connections or not planning the layout to avoid crossing lines can quickly lead to a spiderweb
of connections that is hard to understand.

#### 🏅 Best Practice: Create Visual Balance

Balance is a innate human expectation. Similar to photos, a diagram that is visually balanced will be easier to
understand and appealing to look at. There is no character limit or maximum lines of code per file for diagrams, and
fiddling with mermaid directions to achieve a visually balanced diagram can be annoying, but it is worth the effort.

#### 💡 Best Practice: Match the Flow the User Expects, Tell a Story

A human will find a diagram easier to understand if the flow of information matches their expectations, providing a
start point (of a user journey, a state machine, the main class things evolve around), evolving around the message or
story the diagram should tell, and a conclusion or end point.

While there are cultural differences, western cultures will expect information to flow from left to right and top to
bottom. Anyway, it is easier to follow a flow that is consistent throughout the diagram, and if possible unidirectional.

### Diagram Elements

#### 🏅 Best Practice: Balance Text

Big walls of text obfuscate the message of a diagram. Often test can be reduced or moved into a footnote or legend.

{{< mermaid >}}
graph LR
subgraph Users Reaction
M[Declutter Text and Content]
O[Increased Mental load]
end
subgraph .
L[User needs to declutter the Text from Content]
N[User needs additional mental load to read the text]
end
{{< /mermaid >}}

Like Code, Diagrams should be understandable without comments or additional explanations.
Good naming, understandable composition, carefully chosen colors and style, and known symbols can aid a well formulated
diagram message.

#### 🏅 Best Practice: Add a Legend

Not including a legend means assuming that the User understands all elements, abbreviations, or symbols used.
That assumption will in the end reduce the audience of the diagram, not only because Users unfamiliar with technical
knowledge will not understand it, but also Users of other cultural backgrounds might interpret symbols or colors
differently.

#### ❌ Anti Pattern: Color Overload

Colors should have a meaning - Using too many colors can quickly lead to confusion.
Colors are a great tool provide an additional layer of information, e.g. grouping related items, or indicating
status, risk levels, or role.

{{< alert "comment" >}}
**Choosing Colors is not trivial!**

* Colors should have sufficient contrast to be distinguishable by color-blind users. There are help tools to check color
  contrast, e.g. [Accessibility Checker](https://www.accessibilitychecker.org/color-contrast-checker/).
* Colors should match cultural expectations, e.g. red and green for stop and go, red and blue for hot and cold.
* Colors should be consistent over multiple diagrams and company standards
* Colors should work printed and digitally (check color spaces RGB and CMYK)
  {{< /alert >}}

It is a best practice not to rely solely on colors to convey information, and always use a pattern or at least color hue
to differentiate items, and included their meaning in the legend.

{{< alert "comment" >}}
**Syntax Highlighting Colors in IDEs should have a meaning**: Many IDE Color Schemes are bright and colorful,
highlighting so many parts of the code, that nothing stands out. Modern color schemes should use colors sparingly;
highlighting docs, (magic) constants, and structural information like function or class definitions.
{{< /alert >}} [^colorSchemes]

[^colorSchemes]: [Color overload in IDEs](https://tonsky.me/blog/syntax-highlighting/)

#### 💡 Best Practice: Use Meta Style

Style can also convey information. Using a dashed border for deprecated items or a scribbled style for ideas or future
features. While many choose a style based on personal preference, choosing between Excalidraw or Mermaid can convey much
more information than taste. Every Shape can have meaning by convention or association, and can be much more than style.

#### ❌ Anti Pattern: Misleading the User

Dark Patterns are well famous in UX Design, but can also be applied to Diagrams. Starting an axis at a non-zero value,
using non-linear scales, emotional colors or pictures to influence the User ... Every diagram has a message to convey,
but misleading the User is plain unethical.

[//]: # ()
[//]: # ({{< mermaid >}})

[//]: # ()
[//]: # (graph TB)

[//]: # ()
[//]: # (subgraph A [Diagram Types])

[//]: # (direction TB)

[//]: # (A1&#40;["❌ Wrong Diagram for the User"]&#41;)

[//]: # (A2&#40;["❌ Mixing Levels of Absraction"]&#41;)

[//]: # (A3&#40;["🏅 Representational Consistency"]&#41;)

[//]: # (A4&#40;["💡 Single Responsability"]&#41;)

[//]: # (end)

[//]: # ()
[//]: # (subgraph B [Diagram Layout])

[//]: # (direction TB)

[//]: # (B1&#40;["❌ Boxes in Boxes in Boxes"]&#41;)

[//]: # (B2&#40;["❌ Relationship Spiderweb"]&#41;)

[//]: # (B3&#40;["🏅 Create Visual Balance"]&#41;)

[//]: # (B4&#40;["💡 Match the Expectations, Tell a Story"]&#41;)

[//]: # (end)

[//]: # ()
[//]: # (subgraph C [Diagram Elements])

[//]: # (direction TB)

[//]: # (C1&#40;["🏅 Balance Text"]&#41;)

[//]: # (C2&#40;["🏅 Add a Legend"]&#41;)

[//]: # (C3&#40;["❌ Color Overload"]&#41;)

[//]: # (C4&#40;["💡 Use Meta Style"]&#41;)

[//]: # (C5&#40;["❌ Misleading the User"]&#41;)

[//]: # (end)

[//]: # ()
[//]: # (%% Links)

[//]: # (A -.-> B)

[//]: # (B -.-> C)

[//]: # ()
[//]: # (Z[Legend:)

[//]: # (❌ Antipattern)

[//]: # (🏅 Best Practice)

[//]: # (💡 Inspirational Ideas])

[//]: # (style Z fill:#00000000,stroke:#00000000)

[//]: # ()
[//]: # ({{< /mermaid >}})

## Written Communication

{{< alert "comment" >}}
I wrote a blog post about [Writing Good Documentation]({{< ref "posts/2024-07-writing-documentation" >}}) which I am
still happy with, that covers many aspects also mentioned in this chapter. Therefore I will only highlight a few points
from the book here.
{{< /alert >}}

#### 🏅 Best Practice: Big picture first

As a User of written communication, knowing the order of the things I am going to learn, will help to organize the
information into my mental model. Starting with the big picture provides a narrative, helping to navigate into the
details a user might look for and improves retention of information.

🛠**Minto Pyramid**: The Minto Pyramid Principle is a technique to structure information in a way that is easy to
understand.

1. Start with the key message. For the User it is easier to understand the details if the key idea is known upfront.
2. Write out the details of information to convey with the message.
3. Group related information together, and structure them again into key messages and details.

#### ❌ Anti Pattern: Testing the Audiences Knowledge

The goal of communication is to convey a message. Any word, phrase, or concept that is unknown to the Audience but used
by the communicator will make it harder to convey the message. It is important to know the Audience and what knowledge
to expect from them in regard to technical terms, domain knowledge, language skills / vocabulary, diagram standards, and
cultural context.

{{< alert "comment" >}}
Any documentation should aim for the broadest audience possible. Acronyms are not helpful, especially if they are
not "googleable". If there are terms that require a context to be researchable, a glossary should be provided and the
context to look them up should be given. Domain Driven Design proposes the Ubiquitous Language to create a common
vocabulary throughout a product, that is used by stakeholders, product managers, technical writers, and developers
alike. Consistency in naming and terminology reduces cognitive load and improves communication.
{{< /alert >}}

#### 💡 Know about Biases

Humans show systematic patterns of deviation from rationality in judgment, known as cognitive biases. They can affect
how important we perceive information, how we interpret messages, and how we make decisions based on what we read or
hear. As communicators, being aware of these biases can help us craft messages that are clearer and more effective.

{{< alert "comment" >}}
While the book lists some biases, I recommend reading about the many forms of cognitive biases and logical fallacies
to be aware of them when communicating, not only in written form but also in our daily business and private live.
{{< /alert >}}

#### 🏅 Knowledge Management Principles

* **Product over Project**: Keep the long term focus on domain knowledge that lives beyond the life cycle of a project.
* **Ensure Visibility**: Make knowledge accessible to those who need it. Centralize documentation in a known location,
  with open access for people even from different teams if they work on the same product or domain.
* **Enable Reusability**: Templates and standards for documentation can help to create consistent and reusable knowledge
  artifacts, while also decreasing entry barriers for contributors.
* **Prioritize Searchability**: Structure documentation using Metadata, Tags, and a clear structure.

{{< alert "comment" >}}
Sharing knowledge in an organization is in my experience simultaneously never perceived as well working and always
perceived as easy to improve. The small line between having not documented anything in an accessible way and having
AI generated documentation that no one reads is used by some organizations as metaphoric jump rope.

Especially as somebody who values documentation, reading AI generated walls of texts that look impressive, and yet
spread little information feels frustrating. Having beautiful looking docs that in the end do not convey an easy,
compact, and correct view of the system they aim to model are prone to become **AI Slop**, causing way more workhours
than their creator wanted to save themselves.
{{< /alert >}}

#### 🏅 Best Practice: Get Feedback

Getting feedback from the multiple Audiences is crucial to successful communication. It is the best way to identify
errors and possible optimisations early, establish a dialogue with the Audience, align expectations, evaluate risks, and
share the load of communication and documentation. Like Pull Requests in Software Development, having a review process
is an effective way to ensure quality and establish shared ownership of communication artifacts.

## Conclusion

Looking at the parallels of modeling a system as code and modeling a system in visual communication provides very
interesting point of views. Modern code is designed to be reused, easy to understand, and easy to maintain.
Why not apply the same principles and patterns to communication artifacts as well?

The book also covers much more information about verbal communication, meetings, and presentations, goes into great
detail about the individual patterns, and provides many more examples - after all these are just my personal takeaways,
biased by the knowledge I already had and the ignorance of topics I currently do not appreciate.

Happy coding :) (and communicating)
