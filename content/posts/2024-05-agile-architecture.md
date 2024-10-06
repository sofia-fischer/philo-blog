---
title: "Agile Software Architecture"

date: 2024-05-28T10:20:44+02:00

draft: false

description: Architecture is no longer a set of diagrams that define upfront how features are implemented, but a continuously growing and evolving set of decisions

tags: [ "Development", "Agile" ]
---

{{< lead >}}
Architecture is no longer a set of diagrams that define upfront how features are implemented, but a continuously growing
and evolving set of decisions
{{< /lead >}}

## Agile Architecture

One change that came with the agile culture was replacing detailed architecture plans and class structure diagrams "
YAGNI" mentality of only developing the current ticket losing overview over the bigger picture. Both extremes are not
practical and will end up in an agile architecture.

The term Agile Architecture implies that a software system is designed in a versatile, easy to-evolve, changeable way,
while also being resilient to change; but also that the architecture is contiguously growing in an iterative live cycle
to evolve with respect to the upcoming features of the product.[^agileArchitecture]

[^agileArchitecture]: [How to Agilely Architect an Agile Architecture](https://insights.sei.cmu.edu/documents/1395/2014_101_001_493902.pdf)

In every software project, some decisions need to be made upfront, that will highly influence the architecture of the
project - programming language, database decision, authentication, patterns ...
These decisions should not be solved by the first feature ticket by one developer. But I had the experience that exactly
that happens - one developer gets the task of "build the project", locks themselves in a dark room and emerges after
weeks with a bare bone of a project every other team member is forced to use from that point on.

## Defining Architecture and their Requirements

From my idealistic point of view, the architecture decisions should be discussed in the team, after understanding the
idea of the product, to design an agile architecture that is flexible enough to be iterated on.
For this to work, architecture can not be defined the same way as in Waterfall projects in which the architecture was
designed and set in stone before the first ticket was started. "The software architecture isn't a set of diagrams, it's
not a set of review meetings, it's not a software architecture document, but it is a set of decisions that the team
makes about some critical aspects of the system". [^continousArchitecture]

[^continousArchitecture]:[Continuous Architecture with Kurt Bittner and Pierre Pureur](https://www.infoq.com/podcasts/continuous-architecture/)

### Capturing and Documenting Architecture

Viewing Architecture as a set of decisions makes the Architecture Decision Records a very relatable way of documenting
architecture.
Drawing fancy diagrams - something I enjoy to do - is a great way to document how a system is working, but often enough
the question of why it was built this way is the more important question if developers see themselves confronted with
the need for change.

{{<alert>}}
Architecture Design Records: A set of point in time documentation of architectural decisions, usually stored in the code
base to get information on the thoughts and reasons why the code was implemented in a certain
way. [I wrote more about it in this post](https://www.blog.philodev.one/posts/2023-04-communicating-between-teams/#architecture-decision-records).
{{</alert>}}

The boundary of the architectural decision in contrast to an implementation decision is not easy, by may be defined for
practical reasons - if the cost of changing a decision, it is probably an architectural decision.

### Architecture Perspectives for Requirements

While Agile Methodologies provide a wide range of tools to define the requirements for products from a user and a
business perspective; they often lack the perspective of an architect, future developer, or tester.
When formulating the User Story, the architectural requirements are often left out, which means in agile they are
invisible to time constraints, deadlines, and work recognition.

There is one common framework existing that deals with the definition of such architectural or quality attribute
requirements: The Six Part Scenario

* Source of stimulus (some entity or event, e.g. a user, an attacker)
* Stimulus (condition that needs to be considered, e.g. faulty request)
* Environment (providing context, e.g. during overloaded times, while DB is recovering from an error)
* Artifact (what part of the system is acting)
* Response (activity undertaken after the arrival of the stimulus, e.g. reporting, escalating, restarting)
* Response measure (make the response measurable and testable)
  [^sixpartscenario]

[^sixpartscenario]:[Software Architecture in Practice, Felix Bachman and Mark Klein](https://www.win.tue.nl/~wstomv/edu/2ii45/year-0910/Software_Architecture_in_Practice_2nd_Edition_Chapter4.pdf)

Some examples of these requirements, that highly interfere with the architecture:

* A User requires the handling of a large numbers items by a microservice, in an environment that does not require sync
  processes, but handling of the microservice failing; the services uses an async communication, the current state and
  number of tries should be reported (may lead to a Queue that supports retry mechanisms)
* An event is dispatched to trigger a command, but the command will fail as the Database is currently recovering; the
  command should be retried automatically several times before it fails and reports an error.
* One User requests a separate file format and therefore requires the usage of a different (third party) service instead
  of the most used, in a normal business environment; the system should be able to automatically detect file format by
  input and switch the service used, the used client should be stored and visible to the user. (Might lead to something
  like a driver pattern)
* A User want to authenticate against the system and related microservices in a normal business environment; The
  authentication process should include the permissions to also authenticate against the microservices, the system
  should run without a separate authentication (might lead to something like oAuth)
* A User requests a list of data entries without the need to store something, during a timeslot with very high demand;
  the system should direct such request to a read replica of the DB; the Master-DB statistics should reflect a much
  lower number of only read statements (might lead to Query Command Segregation)

These requirements match partially with the idea of non-functional requirements; but functional requirements do not by
definition have the major impact on development cost.
Architectural / Design Requirements may enable or stop non-functional requirements, and functional requirements should
be consulted to create architectural decisions. How many microseconds a request may take is a non-functional requirement
that may be satisfied without making costly future decisions. As sidenote, the idea of framing non-functional
requirements in a quantitative, measurable, testable number (target number and unacceptable number) also underlines that
these requirements are revisited regularly, influenced by the architecture, but not causing architectural changes per
se  [^nonFuncReqs].

[^nonFuncReqs]: [Non Functional Requirements](https://scaledagileframework.com/nonfunctional-requirements/)

### Documenting Architecture Characteristics (update 06.10.2024)

The analysis that resulted in the Architecture Characteristics will impact their effectiveness. From all architecture
characteristics, the (random number, 7) most important should be documented, with the areas of the system the
characteristics apply to and the sources of the characteristics (like an event storming session).

If the characteristics are measurable, documenting them as
[fitness functions]({{< ref "posts/2024-09-evolutionary-architecture" >}}) can be a great pattern.

## How to design Agile Architecture

### Minimal Viable Architecture

Similar to the concept of a Minimum Viable Product, the idea of a Minimum Viable Architecture is to deliver an
architecture that fulfils the current point in time relevant requirements. This architecture is iterated over in the
upcoming features and requirements.[^mva]

[^mva]: [Minimal Viable Architecture](https://continuousarchitecture.com/2021/12/21/minimum-viable-architecture-how-to-continuously-evolve-an-architectural-design-over-time/)

* *Model the architecture*: The Model should be a tool for communication (not documentation)
* *Consider Alternatives*: Following the LEAN principles, discuss more than one option and consider drawbacks and
  benefits
* *Mind Conways Law*: Companies tend to implement systems that reflect their communication structure. If there is no
  functioning communication structure to the team that builds the service that your system requires, the implementation
  might reflect that
* *Architect for change*: The Architecture will change within the agile process, it can not and should not be defined in
  a way that eliminates future opportunities
* *Mind testability, deploy-ability, and developer usability*: The Devs, Testers, and Infra are the users of the
  architecture that is built. It should be clear and easy to use it.
* *Keep minimal viable*: Travel light - Making too many decisions too early might restrict future implementations. If
  there is a decision that might as well be set in stone later, delay it

### Feedback loops

One of the form my point of view most important perspectives of the Quality Attribute Requirements is the visibility of
the result. How are those architectural requirements visible to the user, the dev (so the user of the code), or the
tester?

Looking at the former requirements, the respective user may be asked if the decisions led to the desired quality
attributes. When a new Developer joins the team, is the code structure easy to follow and understand? How clear is it
for the tester to confirm the testability? How easy is the project to deploy and how often do the architecture decisions
cause interruptions? Do the current devs enjoy working in the architecture?

Refining such quality attributes and assessing them across teams might be a part of the modern interpretation of an
architect's role.

## Conclusion

Architecture is no longer a step in development, but a continuous process of iterative decisions. As those decisions
happen in strong coupling with the current product requirements and the developers who are working on the code they can
and should not be practised in a closed room, but in an open space. Architecture decisions should be documented,
evaluated, experimented, and assessed.

Happy Coding :)
