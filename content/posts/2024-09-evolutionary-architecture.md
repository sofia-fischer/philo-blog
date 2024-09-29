---
title: "📚 Book takeaways: Building Evolutionary Architecture"

date: 2024-09-27T10:20:44+02:00

draft: false

description: With evolving requirements and knowledge about the product, the architecture must evolve as well. This book
  provides an explanation of the concept, examples of fitness functions for architectures, and recommendations on how to
  build incrementally.

tags: [ "Book", "Architecture", "Metrics", "Development" ]
---

{{< lead >}}
Building Evolutionary Architectures
Neal Ford, Rebecca Parsons, Patrick Kua, and Pramod Sadalage.
{{< /lead >}}
[^book]

[^book]: [Building Evolutionary Architectures](https://www.oreilly.com/library/view/building-evolutionary-architectures/9781492097532/)

{{< alert "comment" >}}
**Expectation Management** : This blog post reflects my personal takeaways from the book. Chapters that I did not find
interesting or relevant to my work are not covered, chapters that particularly resonated with me are covered in more
detail. In between I added information I found useful to understand the context of the book.

I will add personal opinion and context in these alerts.
{{< /alert >}}

## Evolutionary Architecture

Evolutionary Algorithms are used for optimization problems, where the search space is too large to be searched.
Inspired by biological evolution, the algorithm uses a population of (more or less random) solutions, and evolves them
over generations. The algorithms utilise a fitness function to evaluate the solutions. the solutions are then modified
by (more or less random) mutations to generate a new population. The generations will be selected and mutated over time
to localise local optimums.

This concept can be transferred to software architecture. With small incremental changes, the architecture can evolve
with the current requirements, while data-driven tested by certain fitness functions to check if the evolution is in the
right direction.

{{< alert "comment" >}}
While the concept and the term fitness function are very helpful when dealing with architecture, I would like to
think about the limitations. Architecture is not only a performance optimization problem, but also a communication tool
to the developers. In a good architecture, developers know why certain decisions have been made, and can use that
understanding to make more decisions. It also a way of communicating guidelines to developers and imply limitations of
the product.
Architects sometimes focus more on the restrictions of developers and communicate through long wiki pages instead of
providing guidance and expectations.

I want to emphasize that the concept of Evolutionary Architecture can be a great tool for communicating the boundaries
and reasons for architectural decisions, but it can also be misused to enforce restrictions on developers, especially if
the fitness functions are written in a way that do not provide the needed context and reason for failure.
{{< /alert >}}

## Mechanics

The mechanics of Evolutionary Architecture are covering fitness functions, as well as practices, metrics, and tools that
support architectural governance.
These mechanics are a tool for architects to guide teams in their architectural decision-making.

### Architecture Characteristics

Software solutions should fulfill the requirements of the product. Defining these requirements is something I wrote
about in a previous blog post about [Agile Architecture]({{< ref "posts/2024-05-agile-architecture.md" >}}).
These architecture characteristics represent critical requirements for the success and maintainability of the product.
The common characteristics in the book include Auditability, Performance, Security, Requirements, Data, Legality,
Scalability.
As the business requirements evolve over time the architectural characteristics utilizes fitness functions to project
the quality of the architecture.

> Decide early what the objective drivers are and prioritize decisions accordingly.

In an agile development environment, many decisions are made incrementally, so should not all architecture decisions be
made upfront, but at the _last responsible moment_. Decisions should bring benefits to the current product, and should
therfore be sacrificial in the possible future of the product.

{{< alert "comment" >}}
One of the most important characteristics of an architecture (in my opinion) is _testability_. An easily testable
system often comes already with its own set of fitness functions.

Testable systems have components that can be tested individually, might use contract testing to conform to outside
expectations, have easy fakable data structures, and provide separations of ports and adapters to test a complete flow.
A system that is easily testable for a developer is often also easier to understand and maintain.
{{< /alert >}}

### Fitness Functions

> An architectural fitness function is any mechanism that provides an objective integrity assessment of some
> architectural characteristic(s).

Fitness functions in practice make take the form of:

* Architecture tests that run against the current implementation to check for architectural definitions, e.g. that
  certain components are not dependent on each other to ensure _maintainability_.
* Monitoring tools that measure e.g. the response time of a service to ensure _performance_.
* Code Metrics that check things like cyclomatic complexity to ensure _maintainability_.
* Chaos Engineering that tests the _resilience_ of the system.
* Security Scanning that check for vulnerabilities to ensure _security_.
* Contract tests ensure _requirements_ are met.

These functions allow a feedback cycle for architecture decisions. A new deployment may be evaluated for its effects on
the architecture fitness functions. As Continuous Deliver strives for data driven results, architecture decisions can
evolve data-driven with the product.

Fitness function may have different characteristics:

**Atomic or Holistic** : Atomic fitness functions are focused on a single context and aspect of the
architecture, like an architecture test that checks for dependencies between components.
Holistic fitness run against shared contexts and for example measure the response time throughout contexts.

**Triggered or Continual or Temporal or Manual** :
Triggered fitness functions are run triggered like an architecture test, most common in the deployment or merge
pipeline.
Continual fitness functions are run continuously like a monitoring tool.
Temporal fitness functions run in defined time frames, like a reminder for a static key rotation or dependency check to
alert on outdated libraries.
Manual fitness functions are run by humans, like a QA review.

{{< alert "comment" >}}
In this context, Monitor Driven Development is mentioned, and seems like something I need to look into!
{{< /alert >}}
[^mdd]

[^mdd]: [Monitor Driven Development](https://benjiweber.co.uk/blog/2015/03/02/monitoring-check-smells/)

**Static or Dynamic results** : Static fitness functions have fixed results like a passed or failed test.
Dynamic fitness functions rely on the context like the response time of a service with increasing numbers of users.

**Intentional or Emerged** :
Intentional fitness functions are defined upfront to project the architecture characteristics.
Emerged fitness functions are defined when a behavior is observed during product development.

### Examples of Fitness functions

There are libraries for many programming languages that can be used to define fitness functions. Some of those must be
precisely defined for the domain, others are more general and can be used in many contexts.

* **Afferent and Efferent Coupling** : Afferent Coupling measures the number incoming connections to a code artifact (
  components, class, etc.), while Efferent Coupling measures the number of outgoing connections. These Couplings are
  should be limited to make the code easy to understand (with all side effects), enable easy testing and if needed easy
  replacement of the code artifact.

```injectablephp
$afferentCoupling = count($incomingConnections);
$efferentCoupling = count($outgoingConnections);
```

* **Abstractness** : The ratio of abstract classes to concrete classes in a package.

```injectablephp
$abstractness = count($abstractClasses) / count($concreteClasses + $abstractClasses);
```

* **Instability** : The ratio of efferent coupling to the total coupling. Higher instability means the code is more
  likely to break if a small portion of it is changed. If a component is changed, the number of resulting, potential
  code changes grows with the instability. On the other hand, a component with low instability is reused more.

```injectablephp
$instability = $efferentCoupling / ($efferentCoupling + $afferentCoupling);
```

* **Distance from the Main Sequence** : Combines the abstractness and instability. A codebase that is too abstract
  becomes difficult to understand and use, while a codebase that is too concrete becomes difficult to change.

```injectablephp
$distanceFromMainSequence = abs($abstractness + $instability - 1);
```

* **Direction of Imports** : It might an architectural decision to let certain components only import from other
  components, but not the other way around. This can be enforced by a fitness function.

* **Cyclomatic Complexity** : The number of independent paths through a code artifact. The metric is taken from graph
  theory and takes the lines of code as edges and the number of decision points (like  `if` or `switch`) as
  the nodes. By this measure a formatted if-else statement in php will generate a complexity of 5 - 1 + 2 = 6, while a
  turnery operator will generate a complexity of 1 - 1 + 2 = 2.
  High cyclomatic complexity makes the code hard to understand and test.
  The industry threshold is value below 10 for complex domains, and below 5 for simple domains.

```injectablephp
$cyclomaticComplexity = count($linesOfCode) - count($decisionsPoints) + 2;
```

* **Communication Governance** : Defining which services are allowed to communicate with each other withing which
  contracts. Services like PACT may be used to define and test these contracts, but additional fitness functions may be
  required to ensure that services without a contract are not allowed to communicate.

* **Chaos Engineering** : The practice of testing the resilience of a system by injecting failures, such as high
  latency, packet loss, whole services or databases going down. Chaos Engineering is a practice that is used to ensure
  that the system is resilient. Netflix is a well-known company that uses Chaos Engineering continuously to ensure
  developers take care of the resilience of their services.

* **Fidelity Fitness** : If a service is replaced by another service, the new service should have the same fidelity as
  the old service. A fidelity fitness function may compare both services side by side to measure to which degree the new
  service has the same feature set, results, or performance.

## Structure

The topology of the software system has a significant impact on the ability to evolve it. The book describes different
form of coupling in software architecture.

### Connascence

> Two components are connascent if a change in one would require the other to be modified in order to maintain the
> overall correctness of the system.

Connascence is a measure of the coupling between components. Different types of Connascence are more desirable than
other, the order of desirability listed here from most strong to weak.

Static Connascence is a measure of the coupling between components on code level, so on what two code artifacts must
agree on to function correctly.

* **Connascence of Name** : Multiple components must agree on the name of an entity.
* **Connascence of Type** : Multiple components must agree on the type of entity.
* **Connascence of Meaning** : Multiple components must agree on the meaning of particular values, like enums.
* **Connascence of Position** : Multiple components must agree on the position of a value, like the order of parameters
  in a function.

Dynamic Connascence is a measure of the coupling between components on runtime level.

* **Connascence of Execution** : Multiple components must agree on the order of execution, like adding a header before
  dispatching a message is a connascence between a messenger component and business code.
* **Connascence of Timing** : If the timing of execution is important, to avoid for example race conditions.
* **Connascence of Value** : If certain values relate to one another to maintain the integrity of the datastructures.
* **Connascence of Identity** : If the identity of an entity must be the same in multiple components.

The Locality of Connascence describes the proximal location to one another in the codebase. As the distance decreases
weaker forms of connascence can be used. Domain Driven Design uses the concept of Bounded Contexts to recognize that
each entity works within a localized context, implying strong connascence within the context and weak connascence
between contexts.

The Degree of Connascence describes the size of impact. A connaissance of type has less impact on a softwaresystem if it
used a normalisation / anti corruption layer to not drag type changes of the other system through it.

The Book provides guidlines from Page-Jones for using connascence to improve systems modularity:

* Minimize overall connascence by breaking the system into encapsulated elements.
* Minimize any remaining connascence that crosses encapsulation boundaries.
* Maximize the connascence within encapsulation boundaries.

### Architectural Quantum

> An architectural quantum is an independently deployable component with high functional cohesion, high static
> coupling, which includes all the structural elements required for the system to function properly.

Independently deployable means that the component can be deployed without the need to deploy other components.
High static coupling refers how services are wired together (in contrast to dynamic coupling, which refers to how
services call one another at run time).
High functional cohesion means it includes all behavior and data to implement a particular domain workflow.

The common example of an architectural quantum is a microservice. Any system that uses a shared database is one
architectural quantum, even if that database is an event storage. High degrees of decoupling into architectural quanta
allows developers to move quickly without being concert about the other services.

Dynamic coupling in quanta is a question of communication (sync or async), (eventual) consistency, and coordination (
orchestrator vs. choreographer).

### Orthogonal Coupling

> Two parts of an architecture may be orthogonally coupled if they serve two distinct purposes that still
> intersect to form a complete solution

An example of such orthogonal coupling would be a service that is responsible for the business logic and a service that
is responsible for monitoring the requests.

{{< alert "comment" >}}
I mark many things here as my opinion, as I am not sure if I got the concepts of the book correctly, and asked for other
help, and think it's worth noting down my learnings, even if they might differ from the book.

Moving the orthogonal coupling to the Kubernetes world, both services would be containers in one pod.
A pod is a small deployable unit in Kubernetes. It is a group of one or more containers,
each container may be defined as Docker Image. The containers in a pod share the same network (the same IP Address) and
storage. The containers in a pod are always deployed together.

Containers that might run in the same pod are for example logging services, or a nginx reverse proxy.
The database is often handled differently, to scale it independently and avoid data loss when their service is
restarted. Only containers are in one pod if they scale together and should exist for each deployment (not application).

Following the concept of orthogonal coupling, any two containers in one pod might be orthogonal coupled.
{{< /alert >}}

This is a concept connected to the Side Car Pattern, in which an application has a service as "side-car" that is managed
more centralized e.g. by the platform team.

{{< alert "comment" >}}
If each pod has a side-car responsible for request handling (in php world for example a nginx), this allows to move
authorization to the side-car completely. Any request in and out of the pod would go through the side-car, so
any tokens can be added or checked in this service. This is a Service Mesh.

If all requests go through this service, it can be used gain monitoring data from the requests, resulting in a map of
requests between all pods in the company as well as to or from the outside. This enables many for example the fitness
function that tests which services are allowed to communicate with each other, if the service communication is
satisfying the contracts, and if there are performance bottlenecks in the communication.
{{< /alert >}}

### Evolutionary Data

> Evolutionary design in databases occurs when developers can build and evolve the structure of the database as
> requirements change over time

This requires migrations to change the database schema:

* Versioned: The database schema is versioned, and migrations are applied in order.
* Incremental: Migrations are applied incrementally, so that the database is always in a consistent state.
* Tested: Migrations are tested to ensure that they work correctly.
* Respect legacy data and integration points: Data migrations should keep data in a backwards compatible way if there
  are dependencies on the data.

Fitness functions may also be used to ensure that data constraints are met, for example that identify is kept throughout
the system, or that data deletions are propagated to other services.

{{< alert "comment" >}}
I am missing the concept of database normalisations in this context. Databases normalisation is a process of organizing
a relational database according to a set of defined rules to ensure data integrity and minimize redundancy.

Depending on the use case the highest normal form of a database is not always the one that satisfies the requirements
the best, still in my experience many databases that where hard to evolve where not normalized enough.
{{< /alert >}}

## My Opinion

Enabling a data driven work flow for architecture decisions is a great way to document and communicate architectural
decisions that will work better than long wiki pages. Fitness functions put technical product goals into code, and make
them measurable.
The book provides a great overview of the concept and examples of fitness functions, and how to implement them into the
development process. In between I also learned more on software topology and the importance of component coupling.
When putting that into practice, the most emphasis lies on the possibility of incremental changes (as in continuous
delivery).

I am looking forward to applying the concept of fitness functions to my work, and maybe I have motivated you to also
read a new book.

Happy coding :)


